# GuardLink

GuardLink is an RP toolkit and nation simulator providing various systems for accounts, economies, laws and more. Everything happens on a centralized server and players interact via client computers. Admins can manage systems through the server shell or remotely via their account. Each server simulates a country/nation/empire with features such as:

- Accounts & Identities
- Wallets & Currencies
- Properties & Real Estate
- Companies & Jobs
- Inter-server interactions (trade, diplomacy, currency exchange)
- Setup wizard

Some features are not fully implemented and/or do not work with every ethic/government type for balancing reasons. See the [wiki](../../wiki) for full documentation.

## Installation

### Server
1. Run `pastebin run zypekhWp`
2. Follow the setup wizard — nation name, tag, ethic, currency, roles
3. If the setup wizard can't detect GPS, follow this [guide](https://tweaked.cc/guide/gps_setup.html)
4. Wait for the server to generate an RSA keypair and register with the certificate authority (this may take a few minutes)
5. Optionally configure roles, permissions, and settings via the shell or UI

### Client
*WIP*

### Client-API
The client API allows you to build your own client applications that connect to a GuardLink server. Some of the networking is handled automatically under the hood.
1. Run `pastebin get VZADGWLr <path>` or copy the [module](https://github.com/GoldeneToilette/GuardLink/blob/main/client_api.lua) manually
2. Follow the [wiki](../../wiki)

## Libraries

- [RSA Key generator](https://gist.github.com/1lann/c9d4d2e7c1f825cad36b)
- [SHA256-Algorithm](https://pastebin.com/6UV4qfNF)
- [Basalt (UI Library)](https://basalt.madefor.cc/#/)
- [Simple XML-Parser for lua](https://github.com/Cluain/Lua-Simple-XML-Parser)
- [pixelbox](https://github.com/9551-Dev/pixelbox_lite)
- [AES Encrypt library](https://forums.computercraft.cc/index.php?topic=487.0)
- [LibDeflate](https://github.com/safeteeWow/LibDeflate)
- [TaskMaster](https://gist.github.com/MCJack123/1678fb2c240052f1480b07e9053d4537)

All original copyright notices and license texts are preserved in the source files. Some files contain modifications, marked with comments. If you believe any licensing requirements have not been met, let me know.

## License

This project is licensed under the [MIT License](https://choosealicense.com/licenses/mit/).