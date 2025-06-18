#!/usr/bin/env python3
"""
Test script for VeSync integration - local testing version
"""
from pyvesync import VeSync
import os

# You'll need to set these environment variables or modify them directly
EMAIL = os.getenv("VESYNC_EMAIL", "your-email@example.com")
PASSWORD = os.getenv("VESYNC_PASSWORD", "your-password")

def test_vesync_connection():
    """Test VeSync connection and list devices"""
    try:
        print("Testing VeSync connection...")
        print(f"Email: {EMAIL}")
        print(f"Password: {'*' * len(PASSWORD)}")
        
        manager = VeSync(EMAIL, PASSWORD)
        print("Attempting to login...")
        manager.login()
        print("✅ Login successful!")
        
        print("Updating device list...")
        manager.update()
        print("✅ Device list updated!")
        
        print("\n=== DEVICE SUMMARY ===")
        print(f"Manager devices type: {type(manager.devices)}")
        print(f"Manager devices value: {manager.devices}")
        
        # Try alternative device access methods
        print(f"Manager outlets: {getattr(manager, 'outlets', 'Not found')}")
        print(f"Manager switches: {getattr(manager, 'switches', 'Not found')}")
        print(f"Manager fans: {getattr(manager, 'fans', 'Not found')}")
        print(f"Manager bulbs: {getattr(manager, 'bulbs', 'Not found')}")
        
        # Check if devices is None or empty
        if manager.devices is None:
            print("⚠️  manager.devices is None - trying alternative approach...")
            
            # Try direct device list access
            all_devices = []
            device_types = ['outlets', 'switches', 'fans', 'bulbs', 'air_purifiers']
            
            for device_type in device_types:
                devices = getattr(manager, device_type, [])
                if devices:
                    print(f"\n📍 Found {device_type}: {len(devices)} devices")
                    for device in devices:
                        all_devices.append((device_type, device))
                        print(f"  • {getattr(device, 'device_name', 'Unknown name')}")
                        print(f"    Type: {type(device).__name__}")
                        print(f"    Status: {getattr(device, 'device_status', 'Unknown')}")
                        
                        # Update device and show all available attributes
                        try:
                            device.update()
                            print(f"    Attributes: {[attr for attr in dir(device) if not attr.startswith('_') and not callable(getattr(device, attr))]}")
                        except Exception as e:
                            print(f"    Error updating device: {e}")
            
            if not all_devices:
                print("\n❌ No devices found through alternative methods either")
                print("Debug info:")
                print(f"  Manager type: {type(manager)}")
                print(f"  Manager dir: {[attr for attr in dir(manager) if not attr.startswith('_')]}")
            else:
                print(f"\n✅ Found {len(all_devices)} total devices!")
                
        else:
            # Original logic if devices is not None
            device_categories = list(manager.devices.keys()) if manager.devices else []
            print(f"Available device categories: {device_categories}")
            
            if device_categories:
                total_devices = sum(len(devices) for devices in manager.devices.values())
                print(f"Total devices found: {total_devices}")
                
                for category, devices in manager.devices.items():
                    print(f"\n� {category.title()} ({len(devices)}):")
                    for device in devices:
                        try:
                            device.update()
                            print(f"  • {getattr(device, 'device_name', 'Unknown')}")
                            print(f"    Type: {type(device).__name__}")
                            print(f"    Status: {getattr(device, 'device_status', 'Unknown')}")
                        except Exception as e:
                            print(f"    Error with device: {e}")
            else:
                print("No device categories found")
        
        print("\n✅ VeSync test completed successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\nTroubleshooting tips:")
        print("1. Check your email and password")
        print("2. Make sure you can login to the VeSync app")
        print("3. Verify your VeSync account has devices")
        return False

if __name__ == "__main__":
    print("VeSync Local Test Script")
    print("=" * 40)
    
    if EMAIL == "your-email@example.com":
        print("⚠️  Please set your VeSync credentials:")
        print("   export VESYNC_EMAIL='your-email@example.com'")
        print("   export VESYNC_PASSWORD='your-password'")
        print("\nOr edit this script directly.")
    else:
        test_vesync_connection()
