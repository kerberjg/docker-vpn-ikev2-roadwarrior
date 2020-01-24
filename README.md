# docker-vpn-ikev2-roadwarrior
Docker container with a Strongswan IKEv2 VPN server (for a mobile-optimized Road Warrior setup)

## Features
- Independent, safe builds of Strongswan
- Uses safest encryption supported (ChaCha20/AES256, NewHope128/ECP256/SHA3-256)
- Automatically generates an Apple VPN Profile (.mobileconfig)

## TODO
- Radius auth support (#1)
- IPv6 Support (#2, help wanted!)
- Search domain configuration for client hostnames
- Test algorithm support
- List supported platforms/OSs