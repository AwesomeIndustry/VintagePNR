# VintagePNR
SIMLessPNR but for iOS 10!

This is just a port of [SIMLessPNRGateway](https://github.com/AwesomeIndustry/SIMLessPNRGateway) that will work on iOS 10.3.3.
This will probably work on iOS 9.x as well (the headers are exactly the same), but Theos was giving me some compilation errors
so right now I've only tested 10.3.3. The headers needed for iOS 10 are almost exactly the same as the headers in iOS 7.x, so
with minimal tweaking this should work on iOS 7 as well (I think some of the status methods in `IDSAppleSMSRegistrationCenter`
took arguments as `long long` instead of `int`)

`ReceivePNR` is unchanged from SIMLessPNRGateway. Also use the same
[PNRGatewayClientV2](https://github.com/AwesomeIndustry/PNRGatewayClientV2) when using VintagePNR.

Happy hacking!
