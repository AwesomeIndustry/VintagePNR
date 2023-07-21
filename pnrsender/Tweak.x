#import <Foundation/NSObject.h>
#import <objc/runtime.h>
#import <SpringBoard/SpringBoard.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>

#import "Tweak.h"
#import "dlfcn.h"


NSString * const ANDROID_PHONE_NUMBER = @"+11234567890";

@interface IDSPreflightMessage
- (void)handleResponseDictionary:(id)arg1;
- (id)bagKey;
- (id)requiredKeys;
- (id)messageBody;
- (id)additionalMessageHeaders;
- (id)copyWithZone:(struct _NSZone *)arg1;

+ (Class) class;

@end

%hook IDSAppleSMSRegistrationCenter

    //IDSAppleSMSRegistrationCenter is the older (iOS 7-10) name for the IDSPhoneNumberValidationStateMachine

    - (long long) status {

        //Overriding this "status" function fixes a problem I ran into when piping in
        //the REG-RESP SMS data--the IDSPhoneNumberValidationStateMachine kept throwing
        //an error that it wasn't in the right state to accept the REG-RESP message.
        //Thus, before PNRGateway hands off the REG-RESP data to the state machine, it
        //sets up the "fakeStatus" instance variable, which causes the state machine
        //to report a status of "3" while it's processing the REG-RESP message. Once
        //it's done, the "fakeStatus" variable is set to nil, going back to letting the
        //state machine modify its status value. (At the end of handleIncomingSMSForPhoneNumber,
        //the state machine changes its real status value to indicate that it's done
        //processing the SMS, so setting "fakeStatus" to nil gives control over the status
        //variable back to the state machine.

        //Known status values:
        // 2: Happens sometime before request SMS is sent
        // 3: Waiting for Authentication Response, I think!!

        id instance = self;
        NSLog(@"PNRGateway: Got status getter call: %lld", %orig);

        id propertyValue = objc_getAssociatedObject(instance, &"fakeStatus");
        if (propertyValue) {
            // If the property exists, do nothing. MRYIPC server has already been created
            NSLog(@"PNRGateway: Fake status exists! Sending that instead: %@", propertyValue);
            return [propertyValue longLongValue];
        } else {
            return %orig;
        }

    };

    %new

    - (void)emulateReceivedResponsePNR:(NSArray *) responseData {

        //Runs when ReceivePNR calls this method through IPC. This sets the rest of
        //the registration process in motion, causing the IDSPhoneNumberValidationStateMachine
        //to accept the REG-RESP data as if it was received via a genuine SMS

        //responseData should be an NSArray with two elements:
        //  1. An NSString with the phone number in international format (i.e. +18882278255)
        //  2. An NSData with the signature data (i.e. <0123 45ab c23d ...>)

        NSLog(@"PNRGateway: Got emulateReceivedResponsePNR call! %@", responseData);

        if (responseData.count != 2) {
            NSLog(@"PNRGateway: Response data has wrong length! %@", responseData);
            return;
        }


        //Sets the fake status to 3, which apparently means "Waiting for authentication response".
        //See the status hook above for more information
        objc_setAssociatedObject(self, &"fakeStatus", @(3), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        //Calls the real handleIncomingSMSForPhoneNumber method in IDSPhoneNumberValidationStateMachine, which will
        //  give the phone number and signature back to the state machine, which will complete phone number registration
        //  for the Android phone number!
        NSLog(@"PNRGateway: Calling handleIncomingSMSForPhoneNumber");
        [self handleIncomingSMSForPhoneNumber:responseData[0] signature:responseData[1]];
        NSLog(@"PNRGateway: Finished calling handleIncomingSMSForPhoneNumber");

        //Erases the fake status to make sure it can proceed through the rest of the
        //registration process. See the status hook above for more information
        objc_setAssociatedObject(self, &"fakeStatus", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }

    %new

    - (void) ensureIPCIsSetUp {
        //This method just makes sure that the MRYIPC center is set up, so
        //the emulateReceivedResponsePNR method can run when called by ReceivePNR (via IPC)

        id instance = self;

        // Check if the property exists
        id propertyValue = objc_getAssociatedObject(instance, &"HasSetUpMRYIPC");
        if (propertyValue) {
            // If the property exists, do nothing. MRYIPC server has already been created
            NSLog(@"PNRGateway: MRYIPC center already exists! Value is %@", propertyValue);
        } else {

            NSLog(@"PNRGateway: Overriding _CTServerConnectionIsUserIdentityModuleRequired");

            // If the property doesn't exist, create it
            NSLog(@"PNRGateway: MRYIPC center does not exist, creating...");

            NSLog(@"PNRGateway: Setting up the MRYIPCCenter");
            MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"dev.altavision.SIMLessPNR"];
            NSLog(@"PNRGateway: MRYIPCCenter is %@", center);

            [center addTarget:^id(NSArray *responseData) {
                // Runs emulateReceivedResponsePNR when data is received via IPC
                NSLog(@"PNRGateway: IPC center test success!!");
                NSLog(@"PNRGateway: State machine reference: %@", self);
                NSLog(@"PNRGateway: Response data is %@", responseData);
                [self emulateReceivedResponsePNR:responseData];

                return nil;
            } forSelector:@selector(performResponse:)];


            objc_setAssociatedObject(instance, &"HasSetUpMRYIPC", center, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }


    }



    - (id) init {
        NSLog(@"PNRGateway: State machine initialized!!");

        //Erases the fake status to make sure it can proceed through the rest of the
        //registration process. See the status hook above for more information
        objc_setAssociatedObject(self, &"fakeStatus", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        [self ensureIPCIsSetUp]; //Ensures the IPC center is set up to allow communication with ReceivePNR script

        return %orig;
    }

    //TODO: Maybe look at _IDSFetchPhoneNumber ?

    - (id)initWithHTTPDelivery:(id)arg1 lockdownManager:(id)arg2 arbiter:(id)arg3 deviceSupport:(id)arg4 systemAccountAdapter:(id)arg5 {

        NSLog(@"PNRGateway: State machine: Initialized via HTTP delivery instead of in normal mode :(");

        //Erases the fake status to make sure it can proceed through the rest of the
        //registration process. See the status hook above for more information
        objc_setAssociatedObject(self, &"fakeStatus", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self ensureIPCIsSetUp];

        return %orig;
    };

    - (void)_registrationStateChangedNotification:(id)arg1 {
        NSLog(@"PNRGateway: Registration state changed notification: %@", arg1);
        %orig;
    };

    - (void)_checkRegistrationStatus {
        NSLog(@"PNRGateway: Device checked registration status");
        %orig;
    }

    - (long long)_registrationControlStatus {
        long long originalStatus = %orig;
        NSLog(@"Device queried registration control status: %lld", originalStatus);
        return originalStatus;
    }

    - (void)_sendPreflightVerificationWithIMSI:(id)arg1 PLMN:(id)arg2 {
        NSLog(@"PNRGateway: Sent preflight verification with IMSI: arg1: %@ and arg2: %@", arg1, arg2);
        %orig;
    }

    - (void)_popHighestPriorityPreflightVerification {
        NSLog(@"PNRGateway: Called _popHighestPriorityPreflightVerification");
        %orig;
    }
    - (void)_sendPreflightVerificationIfNeeded {

        //This bypasses the preflight entirely and jumps straight to trying to send the SMS.
        //(This was another attempt to thwart error 6001 and I'm too worried to remove it)

        NSLog(@"PNRGateway: Called _sendPreflightVerificationIfNeeded");
        [self _sendSMSVerification];
    }

    - (void)_sendSMSVerification {
        NSLog(@"PNRGateway: Got _sendSMSVerificationWithMechanism call");
        [self ensureIPCIsSetUp];
        %orig;
    }

    - (void)_issueAsyncCoreTelephonyPhoneNumberValidationRequestWithPushToken:(id)arg1 mechanism:(id)arg2 {

        //This is where identityservicesd tries to set the verification process in motion.
        //As we're taking over this process, we log the push token (this push token needs
        //to be sent to the Android phone) and then don't call %orig to prevent the device
        //from trying (and failing) to send the SMS.

        [self ensureIPCIsSetUp];
        NSLog(@">>>>>>>>>>>>>>>>>>>>>> PNRGateway: Push Token Received! %@", arg1);

    }

    - (void)_failPromisesWithError:(long long)arg1 {
        NSLog(@"PNRGateway: Called _failPromisesWithError: %lld", arg1);
        %orig;
    }
    - (void)_fulfillPromisesWithPhoneNumber:(id)arg1 token:(id)arg2 {
        NSLog(@"PNRGateway: Called _fulfillPromisesWithPhoneNumber: %@, %@", arg1, arg2);
        %orig;
    }
    - (void)_notifySuccess:(id)arg1 token:(id)arg2 {
        NSLog(@"PNRGateway: Called _notifySuccess: %@, token: %@", arg1, arg2);
        %orig;
    }
    - (void)_notifyFailureWithError:(long long)arg1 {

        //Most of the errors in the early registration stages (anything before the HTTP
        //registration step) come through here, so this just makes sure they are
        //easy to find in the logs.

        NSLog(@"PNRGateway:Called _notifyFailureWithError: %lld", arg1);


        if (arg1 == 36) { //Error code 36 = Failed preflight
            NSLog(@"========> [!] [!] [!] ERROR: PNRGateway: Failed preflight request");
        } else if (arg1 == 2) {
            NSLog(@"PNRGateway: Not registering because user denied it");
        }

        %orig;
    }
    - (void)_performHighestPriorityPreflightVerification {
        NSLog(@"PNRGateway:Called _performHighestPriorityPreflightVerification");
        %orig;
    }
    - (void)pnrRequestSent:(id)arg1 pnrReqData:(id)arg2 {
        NSLog(@"PNRGateway: Device says PNR Request sent: %@ and %@", arg1, arg2);
        %orig;
    }
    - (void)handleRegistrationSMSSuccessfullyDeliveredWithTelephonyTimeout:(id)arg1 {
        NSLog(@"PNRGateway: Device says registration SMS successfully delivered: %@", arg1);
        %orig;
    }
    - (void)handleRegistrationSMSDeliveryFailedWithShouldBypassRetry:(_Bool)arg1 {
        NSLog(@"PNRGateway: Device says SMS delivery failed: %d", arg1);
        %orig;
    }
    - (void)handleRegistrationSMSDeliveryFailed {
        NSLog(@"PNRGateway: Device says SMS delivery failed");
        %orig;
    }
    - (void)_tryToSendSMSIdentification {
        //This is really here just to notify us (i.e. the users watching the log messages)
        //that the device has begun trying to send SMS identification and is in a state to
        //receive the REG-RESP message. Don't run ReceivePNR until you see this message
        //appear in the logs.

        //For a more full-featured app that automatically tells the Android phone to send
        //its SMS, make sure to only tell the Android phone to start doing that once this
        //method runs and it has the push token.
        NSLog(@">>>>>>>>>>>>>>>>>>>>>> PNRGateway: Device tried to send SMS Identification!");

        %orig;
    }


    - (void)handleIncomingSMSForPhoneNumber:(id)arg1 signature:(id)arg2 {
        //This is the method that will get the IDSPhoneNumberValidationStateMachine to finish registration after
        //  the SMS is received from the Android phone. The hooked code doesn't do anything of substance, just a
        //  little logging to make sure it's being called. The state machine handles the rest of the registration
        //  from here.

        %log;
        NSLog(@"PNRGateway: Finishing phone number registration!");
        NSObject *a1 = arg1; //"+11234567890", __NSCFString__
        NSObject *a2 = arg2; //<ca21c50c 645469b2 5f4b65c3 8a7dcec5 6592e038 f39489f3 5c7cd697 2d>, _NSInlineData

        NSLog(@"PNRGateway: arg1: %@", arg1);
        NSLog(@"PNRGateway: Type of arg1: %@", NSStringFromClass(a1.class));

        NSLog(@"PNRGateway: arg2: %@", arg2);
        NSLog(@"PNRGateway: Type of arg2: %@", NSStringFromClass(a2.class));

        %orig;
    }

    - (BOOL)_canDeliverSMSNow {
        NSLog(@"PNRGateway: Got _canDeliverSMSNow call");
        return YES;
    }
    - (BOOL)_deviceCanRegisterPresently {
        NSLog(@"PNRGateway: Got _deviceCanRegisterPresently call");
        return YES;
    }



%end

%hook IDSAppleRegistration

    //This appears to be the equivalent of IDSRegistration--this handles HTTP registration after
    //the two SMSes go through.

    - (NSNumber *) isCDMA {
        return @(0);
    }
    - (NSData *) pushToken {
        NSData *origVal = %orig;
        NSLog(@">>>>>>>>>>>>>>>>>>>>>> PNRGateway: Push Token Received! %@", origVal);
        return origVal;
    }
    - (BOOL) canSendRegistration {
        NSLog(@"PNRGateway: canSendRegistration call");
        return YES;
    }
    - (BOOL) canRegister {
        NSLog(@"PNRGateway: canRegister call");
        return YES;
    }
    - (void)voidPassword {
        NSLog(@"PNRGateway: Got voidPassword call");
        %orig;
    };
    - (NSString *) phoneNumber {
        NSLog(@"PNRGateway: got phoneNumber property call");
        return ANDROID_PHONE_NUMBER;
    }
    - (id)initWithDictionary:(id)arg1 {
        NSLog(@"PNRGateway: Got initWithDictionary call! %@", arg1);
        return %orig;
    }
    - (id)init {
        NSLog(@"PNRGateway: Got init call!");
        return %orig;
    }

%end

%hook IDSAppleRegistrationController


- (void)_SIMRemoved:(id)arg1 {
    NSLog(@"PNRGateway: Prevented device from being notified the SIM was removed");
}
+ (BOOL)validSIMStateForRegistration {
    NSLog(@"PNRGateway: got validSIMStateForRegistration");
    return YES;
}

- (BOOL)validSIMStateForRegistration {
    NSLog(@"PNRGateway: got validSIMStateForRegistration");
    return YES;
}

- (_Bool)systemSupportsServiceType:(id)arg1 registrationType:(long long)arg2 {
    if ([arg1 isEqualToString:@"iMessage"] && arg2 == 0) {
        //No idea if this actually works to ensure iMessage activates,
        //but I'm keeping it here just for safety
        return YES;
    }
    return %orig;
}
- (_Bool)systemSupportsServiceType:(id)arg1 accountType:(int)arg2 {
    //I believe account type 0 is SMS PNR?

    if ([arg1 isEqualToString:@"iMessage"] && arg2 == 0) {
        //No idea if this actually works to ensure iMessage activates,
        //but I'm keeping it here just for safety
        return YES;
    }
    return %orig;
}



%end

%hook IMMobileNetworkManager

    //Used to trick the HTTP registration step to work without a SIM card

    -(bool)requiresSIMInserted {
        return NO;
    }

    - (BOOL) inValidSIMState {
        return YES;
    }

    -(BOOL)isSIMRemoved {
        return NO;
    }

%end;
