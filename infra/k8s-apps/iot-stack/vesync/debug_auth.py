#!/usr/bin/env python3
"""
VeSync Authentication Debug Script
"""
from pyvesync import VeSync
import os
import logging

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)

# You'll need to set these environment variables
EMAIL = os.getenv("VESYNC_EMAIL", "your-email@example.com")
PASSWORD = os.getenv("VESYNC_PASSWORD", "your-password")

def debug_vesync_auth():
    """Debug VeSync authentication issues"""
    try:
        print("VeSync Authentication Debug")
        print("=" * 40)
        print(f"Email: {EMAIL}")
        print(f"Password length: {len(PASSWORD)} characters")
        print(f"Password starts with: {PASSWORD[:3]}...")
        
        if PASSWORD == "your-actual-password":
            print("\n❌ Please set your actual VeSync password!")
            print("export VESYNC_PASSWORD='your-real-password'")
            return False
        
        print("\nCreating VeSync manager...")
        manager = VeSync(EMAIL, PASSWORD, debug=True)
        
        print("\nAttempting login...")
        login_result = manager.login()
        print(f"Login result: {login_result}")
        
        if hasattr(manager, 'token') and manager.token:
            print(f"✅ Authentication token received: {manager.token[:20]}...")
        else:
            print("❌ No authentication token received")
        
        if hasattr(manager, 'account_id') and manager.account_id:
            print(f"✅ Account ID: {manager.account_id}")
        else:
            print("❌ No account ID received")
        
        print("\nTrying device update...")
        update_result = manager.update()
        print(f"Update result: {update_result}")
        
        return login_result
        
    except Exception as e:
        print(f"❌ Exception occurred: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = debug_vesync_auth()
    
    if not success:
        print("\n🔧 Troubleshooting Steps:")
        print("1. Double-check your VeSync email and password")
        print("2. Try logging into the VeSync mobile app to verify credentials")
        print("3. Disable 2FA temporarily if enabled")
        print("4. Check if your region requires a different API endpoint")
        print("5. Try again after a few minutes (rate limiting)")
