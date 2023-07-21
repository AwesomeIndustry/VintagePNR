# VintagePNR
SIMLessPNR but for iOS 10!

This is just a port of [SIMLessPNRGateway](https://github.com/AwesomeIndustry/SIMLessPNRGateway) that will work on iOS 10.3.3.
This will probably work on iOS 9.x as well (the headers are exactly the same), but Theos was giving me some compilation errors
so right now I've only tested 10.3.3. The headers needed for iOS 10 are almost exactly the same as the headers in iOS 7.x, so
with minimal tweaking this should work on iOS 7 as well (I think some of the status methods in `IDSAppleSMSRegistrationCenter`
took arguments as `long long` instead of `int`)

`ReceivePNR` is unchanged from SIMLessPNRGateway. Also use the same
[PNRGatewayClientV2](https://github.com/AwesomeIndustry/PNRGatewayClientV2) when using VintagePNR.

Full instructions and an explainer are over on the SIMLessPNRGateway repo, but here's a quick guide to get it up and running:

## How to build SIMLessPNRGateway

1. [Install theos](https://theos.dev/docs/installation) if you haven't already
2. `cd` into the project directory
3. Make sure to set the `ANDROID_PHONE_NUMBER` at the top of `Tweak.x`
4. Run `make package`. This creates a `.deb` file in the `packages` directory--transfer that to your iOS device and install it.
5. Alternatively to step (3), if you have SSH enabled on your iPhone, open the Makefile and change `THEOS_DEVICE_IP` to your iPhone's IP Address, and then run `make package install`. You'll have to enter your iPhone password twice (the default password is alpine)

## How to use/test SIMLessPNRGateway

You'll need an iPhone to test this tweak, preferably on iOS 9.x or 10.x. 8.x and 7.x will probably work with minimal tweaking
but are untested. I used the [Legacy iOS Kit](https://github.com/LukeZGD/Legacy-iOS-Kit) on my iPhone 5S to downgrade it to 10.3.3


You'll also need to have [PNRGatewayClientV2](https://github.com/AwesomeIndustry/PNRGatewayClientV2) installed on your Android phone, with notification and SMS permissions.


You'll also need a way to view your iPhone's logs. The Console app on Mac appears to be the easiest way to do that


It's also super helpful to have a quick way to send snippets of text between your computer and Android phone. Any messaging app installed on both will do just fine

1. Ensure FaceTime and iMessage are both turned off in the iPhone settings. Also make sure you're SSHed into your iPhone on your computer
2. Make sure your gateway address is set correctly in the Android app. This is the Apple phone number that your phone talks to to receive the SMS. This varies by carrier--on AT&T it's `28818773`, on T-Mobile MVNOs (like Google Fi) it's `22223333`, and on lots of other carriers it's `+447786205094`. If you're unsure, you can usually find it on your iPhone by downloading Filza and looking in `/System/Library/Carrier Bundles/iPhone/[your carrier]/carrier.bundle` under `PhoneNumberRegistrationGatewayAddress`.
3. Modify `ANDROID_PHONE_NUMBER` at the top of `pnrsender/Tweak.x` to your Android phone's number (in international format)
4. Install Theos and run `make package` inside both `pnrsender` and `receivepnr` and install both .deb files to your device. You could also use `make package install` if Theos and your iPhone are set up with SSH
5. At this stage, I like to SSH into my iPhone and `killall identityservicesd` for good measure
6. Open the Console app on your Mac and filter for "PNRGateway". (All the log messages from the tweak start with PNRGateway so it's easy to filter for them)
7. Open Settings on the iPhone and select "Messages". Switch iMessage on. If no log messages appear, `killall identityservicesd`, turn off iMessage, and try again.
8. In the Console app on your Mac, you should see a log message like `>>>> PNRGateway: Push Token Received!` Copy this entire log message and paste it into the PNRGatewayClientV2 Android app. Don't click Send just yet!
9. Make sure you can see a log message that says `>>>>> PNRGateway: Device tried to send SMS Identification!`. Once you can, click "Send REG-REQ SMS!" in the Android app
10. You should see a notification on your Android phone that says "REG-RESP Message Received!" Click Copy, which will copy the "REG-RESP?v=3..." message to your clipboard
11. On the SSH session on your computer, run `ReceivePNR "[REG-RESP message you copied earlier]"`, pasting in the REG-RESP message you copied from the Android phone
12. That's it! With a little luck, your iPhone should show your Android phone's number as registered for iMessage, and you should be able to send iMessages to your phone number while keeping your SIM in your Android phone!
