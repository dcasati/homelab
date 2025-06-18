#!/usr/bin/env python3
"""
VeSync Air Purifier Data Collection Script for Kubernetes
Collects air purifier data and writes to InfluxDB
"""

import os
import sys
import logging
from datetime import datetime, timezone
from pyvesync import VeSync
from influxdb import InfluxDBClient

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def collect_vesync_data():
    """Collect data from VeSync air purifiers and write to InfluxDB"""
    
    # Get environment variables
    email = os.getenv("VESYNC_EMAIL")
    password = os.getenv("VESYNC_PASSWORD")
    influxdb_host = os.getenv("INFLUXDB_HOST", "influxdb-service.iot-stack.svc.cluster.local")
    influxdb_port = int(os.getenv("INFLUXDB_PORT", "8086"))
    influxdb_database = os.getenv("INFLUXDB_DATABASE", "homelab")
    
    if not email or not password:
        logger.error("VESYNC_EMAIL and VESYNC_PASSWORD environment variables are required")
        sys.exit(1)
    
    logger.info("Starting VeSync data collection")
    
    try:
        # Initialize VeSync manager
        manager = VeSync(email, password)
        
        # Login and update device list
        logger.info("Logging into VeSync...")
        if not manager.login():
            logger.error("Failed to login to VeSync")
            sys.exit(1)
        
        logger.info("Updating device list...")
        manager.update()
        
        # Log discovered devices
        logger.info(f"Found {len(manager.fans)} air purifier(s)")
        
        if not manager.fans:
            logger.warning("No air purifiers found")
            return
        
        # Connect to InfluxDB
        logger.info(f"Connecting to InfluxDB at {influxdb_host}:{influxdb_port}")
        influx_client = InfluxDBClient(
            host=influxdb_host,
            port=influxdb_port,
            database=influxdb_database
        )
        
        # Create database if it doesn't exist
        influx_client.create_database(influxdb_database)
        
        # Collect data from each air purifier
        data_points = []
        current_time = datetime.now(timezone.utc).isoformat()
        
        for device in manager.fans:
            logger.info(f"Processing device: {device.device_name}")
            
            # Update device status
            device.update()
            
            # Prepare data point
            tags = {
                "device_name": device.device_name,
                "device_type": "air_purifier"
            }
            
            fields = {}
            
            # Collect available metrics
            if hasattr(device, 'air_quality') and device.air_quality is not None:
                try:
                    fields["air_quality"] = int(device.air_quality)
                except (ValueError, TypeError):
                    logger.warning(f"Could not convert air_quality to int: {device.air_quality}")
            
            if hasattr(device, 'mode') and device.mode is not None:
                fields["mode"] = str(device.mode)
            
            if hasattr(device, 'fan_speed') and device.fan_speed is not None:
                try:
                    fields["fan_speed"] = int(device.fan_speed)
                except (ValueError, TypeError):
                    logger.warning(f"Could not convert fan_speed to int: {device.fan_speed}")
            
            if hasattr(device, 'filter_life') and device.filter_life is not None:
                try:
                    fields["filter_life"] = int(device.filter_life)
                except (ValueError, TypeError):
                    logger.warning(f"Could not convert filter_life to int: {device.filter_life}")
            
            if hasattr(device, 'is_on') and device.is_on is not None:
                fields["is_on"] = bool(device.is_on)
            
            if hasattr(device, 'display') and device.display is not None:
                fields["display"] = bool(device.display)
            
            if hasattr(device, 'child_lock') and device.child_lock is not None:
                fields["child_lock"] = bool(device.child_lock)
            
            if hasattr(device, 'night_light') and device.night_light is not None:
                fields["night_light"] = str(device.night_light)
            
            # Only add data point if we have some fields
            if fields:
                data_point = {
                    "measurement": "vesync_air_purifier",
                    "tags": tags,
                    "time": current_time,
                    "fields": fields
                }
                data_points.append(data_point)
                
                logger.info(f"Collected data for {device.device_name}: {len(fields)} metrics")
            else:
                logger.warning(f"No valid data collected for {device.device_name}")
        
        # Write data to InfluxDB
        if data_points:
            logger.info(f"Writing {len(data_points)} data points to InfluxDB")
            influx_client.write_points(data_points)
            logger.info("Data successfully written to InfluxDB")
        else:
            logger.warning("No data points to write")
        
        # Close InfluxDB connection
        influx_client.close()
        
    except Exception as e:
        logger.error(f"Error during data collection: {e}")
        sys.exit(1)

if __name__ == "__main__":
    collect_vesync_data()
