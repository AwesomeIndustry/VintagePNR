@class CTXPCSimLessContexts;
@class CTServiceDescriptorContainer;
@class CTXPCContexts;
@class CTXPCServiceSubscriptionInfo;
@class CTServiceDescriptorContainer;
@class CTXPCSimLessContexts;



//FUTURE: Maybe create a CTXPCServiceSubscriptionContext? Not sure if that's left over from when I had a SIM in this thing

@class CTXPCServiceSubscriptionContext;
@class CTPNRContextInfo;
@class CTPNRRequestType;
@class CDUnknownBlockType;

@interface IDSPhoneNumberValidationMechanism
    + (id)SMSMechanismWithContext:(_Nullable id)arg1;
    - (id)description;
    - (id)initWithType:(long long)arg1 context:(id)arg2;

@end

@class CTXPCServiceSubscriptionContext;
@class CTPhoneBookEntry;
@class PSEditableTableCell;

@class IDSRegistration;
@class IDSDService;
@class KeychainSyncCountryInfo;

@class NSObject;
@class NSConcreteNotification;
@class IMMessage;




@interface IDSPhoneNumberValidationStateMachineDeviceSupport

    - (NSDictionary *)registrationState;
    - (_Bool)supportsSMSIdentification;

@end


@interface IDSAppleSMSRegistrationCenter
+ (id)sharedInstance;
@property(readonly, nonatomic) int status; // @synthesize status=_status;
- (void)heartbeat;
- (void)cancelActionsForRegistrationInfo:(id)arg1;
- (void)sendRegistration:(id)arg1;
- (void)removeListener:(id)arg1;
- (void)addListener:(id)arg1;
- (void)userNotificationDidFinish:(id)arg1;
- (void)timedOutWaitingForSMS;
- (void)resetSMSCounter;
- (void)handleIncomingSMSForPhoneNumber:(id)arg1 signature:(id)arg2;
- (void)handleRegistrationSMSSuccessfullyDelivered:(id)arg1;
- (void)handleRegistrationSMSDeliveryFailed:(id)arg1;
- (void)handlePhoneNumberChangedNotification:(id)arg1;
- (void)handlePhoneNumberRegistrationStateChangedNotification:(id)arg1;
- (void)_checkRegistrationStatus;
- (void)_tryToSendSMSIdentification;
- (void)_sendSMSVerification;
- (void)_setSMSDeliveryTimeout:(double)arg1;
- (BOOL)_canDeliverSMSNow;
- (void)_smsDeliveryClear;
- (void)_clearSMSDeliveryTimeout;
- (void)_keychainMigrationComplete:(id)arg1;
- (void)systemRestoreStateDidChange;
- (void)systemDidStopBackup;
- (void)systemDidFinishMigration;
- (void)_deviceIDChangedNotification:(id)arg1;
- (void)_registrationStateChangedNotification:(id)arg1;
- (void)_airplaneModeChangedNotification:(id)arg1;
- (void)_registerForLockdownNotifications;
- (void)_lockdownStateChanged:(id)arg1;
- (void)_unregisterForCarrierNotifications;
- (void)_registerForCarrierNotifications;
- (void)carrierSettingsChanged:(id)arg1;
- (BOOL)_deviceCanRegisterPresently;
- (void)_daemonShuttingDown:(id)arg1;
- (void)_notifySuccess:(id)arg1 token:(id)arg2;
- (void)_notifyFailureWithError:(int)arg1 registration:(id)arg2;
- (void)_notifyNeedsNewIdentification:(id)arg1;
@property(readonly, nonatomic) BOOL carrierSupportsShortCode;
- (struct __CTServerConnection *)ctServer;
- (void)_startupCoreTelephony;
- (void)_handleSMSAddressAvailable;
- (void)_unregisterForCoreTelephonyNotifications;
- (void)_registerForCoreTelephonyNotifications;
- (void)_unregisterForCommCenterReadyNotifications;
- (void)_registerForCommCenterReadyNotifications;
- (void)_registerForDeviceCenterNotifications;
- (void)_commCenterAlive;
- (void)dealloc;
- (id)init;
- (BOOL)_failIfRegistrationIsNotSupported;
- (void)_scheduleHeartbeat:(double)arg1;

- (void)emulateReceivedResponsePNR:(NSArray *) responseData;
- (void) ensureIPCIsSetUp;
@end

@interface IDSRegistrationController

    + (_Bool)systemSupportsRegistrationInfo:(id)arg1;	// IMP=0x000000010004b8e0
    + (_Bool)systemSupportsServiceType:(id)arg1 registrationType:(long long)arg2f;	// IMP=0x000000010004b33c
    + (_Bool)systemSupportsServiceType:(id)arg1 accountType:(int)arg2;	// IMP=0x000000010004b2c4
    + (_Bool)validSIMStateForRegistration;	// IMP=0x000000010004b024
    - (void)_SIMRemoved:(id)arg1;	// IMP=0x0000000100052690
    - (void)_SIMInserted:(id)arg1;	// IMP=0x00000001000522b8
    - (_Bool)validSIMStateForRegistration;	// IMP=0x000000010004b2a0
    - (_Bool)systemSupportsRegistrationInfo:(id)arg1;	// IMP=0x000000010004baf8
    - (_Bool)systemSupportsServiceType:(id)arg1 registrationType:(long long)arg2;	// IMP=0x000000010004ba8c
    - (_Bool)systemSupportsServiceType:(id)arg1 accountType:(int)arg2;	// IMP=0x000000010004ba20

@end

@interface IDSRegistration

    - (NSString *) phoneNumber;
    - (_Bool) canSendRegistration;
    - (_Bool) canRegister;

@end


@interface IDSDAccountController

    - (_Bool)_hasActiveSMSAccount;	// IMP=0x00000001000fac68
    - (void)_SIMInserted:(id)arg1;	// IMP=0x00000001000f5278
    - (_Bool)isEnabledAccount:(id)arg1;
    - (id)_accountsForService:(id)arg1 onIvarQueue:(_Bool)arg2;	// IMP=0x00000001000ecc90

@end


@interface CTXPCClientHandler

    - (void)getPNRContext:(id)arg1 completion:(id)arg2;
    - (void)issuePNRRequest:(id)arg1 pnrReqType:(id)arg2 completion:(id)arg3; //arg3 is a callba
    - (void)isPNRSupported:(id)arg1 completion:(id)arg2; //arg2 is a callba

@end



@interface CTXPCServicePNRInterface

    - (void)isPhoneNumberCredentialValid:(CTXPCServiceSubscriptionContext *)arg1 completion:(void (^)(_Bool, NSError *))arg2;
    - (void)getPNRContext:(CTXPCServiceSubscriptionContext *)arg1 completion:(void (^)(CTPNRContextInfo *, NSError *))arg2; //Oooooo, is this where the context comes from?
    - (void)issuePNRRequest:(CTXPCServiceSubscriptionContext *)arg1 pnrReqType:(CTPNRRequestType *)arg2 completion:(void (^)(_Bool, _Bool, NSError *))arg3;
    - (void)isPNRSupported:(CTXPCServiceSubscriptionContext *)arg1 completion:(void (^)(_Bool, NSError *))arg2;

@end

@interface CTXPCServiceSubscriptionContext

    -(BOOL)isSimPresent;
    -(void)setIsSimPresent:(BOOL)arg1;
    -(void)setPhoneNumber:(NSString *)arg1;
    -(void)setLabelID:(NSString *)arg1;
    -(id)initWithSlot:(long long)arg1;
    -(id)context;
    -(NSString *)label;
    -(NSString *)phoneNumber;

@end

//FTSelectedPNRSubscription in FTServices
// https://developer.limneos.net/index.php?ios=12.1&framework=FTServices.framework&header=FTSelectedPNRSubscription.h

@interface FTSelectedPNRSubscription

    +(BOOL)isPhoneNumber:(id)arg1 equivalentToExistingPhoneNumber:(id)arg2;
    -(id)_firstPresentSubscriptionFromAvailableSubscriptions:(id)arg1;
    -(id)selectedRegistrationPhoneNumberWithError:(id*)arg1;
    -(BOOL)isDeviceInDualPhoneIdentityMode;
    -(id)_subscriptionFromAvailableSubscriptions:(id)arg1 matchingSelectedLabel:(id)arg2;
    -(id)setSelectedPhoneNumberRegistrationSubscriptionNumber:(id)arg1;
    -(BOOL)isPhoneNumberEmergencyNumber:(id)arg1;
    -(id)selectedPhoneNumberRegistrationSubscriptionWithError:(id*)arg1;
    -(BOOL)_doesSubscriptionInfoContainMultipleUniqueLabels:(id)arg1;
    -(id)init;
    -(void)persistSelectedPhoneNumberRegistrationSubscriptionIfNeede;
    -(id)_reevaluateCachedActiveSubscriptionWithError:(id*)arg1;
    -(BOOL)_legacy_isPhoneNumberEmergencyNumber:(id)arg1;
    -(BOOL)_isInDualPhoneIdentityModeBasedOnCapability:(long long)arg1;
    -(void)dualSimCapabilityDidChange;
    -(void)dealloc;
    -(void)phoneNumberAvailable:(id)arg1; //Is arg1 a callbac;
    -(BOOL)_doesSubscriptionInfoContainMultipleLabels:(id)arg1;
    -(void)activeSubscriptionsDidChange; //Looks like this runs whenever the subscription chang;
    -(id)_reevaluateCachedSelectedPhoneNumberRegistrationWithSubscription:(id)arg1 activeContexts:(id)arg2 fallbackProhibited:(BOOL)arg3 persistUpdate:(BOOL)arg4 error:(id*)arg5;
    -(id)_reevaluateCachedSubscriptionWithError:(id*)arg1;
    -(id)_reevaluateCachedSelectedPhoneNumberWithContext:(id)arg1 error:(id*)arg2;
    -(void)_reevaluateDualIdentityModeWithSubscriptionInfo:(id)arg1;
    -(void)phoneNumberChanged:(id)arg1;
    -(BOOL)_isIdentityFallbackProhibitedForDeviceBasedOnCapability:(long long)arg1 subscriptionInfo:(id)arg2;
    -(id)_protected_reevaluateCacheIfNeededAndPersistUpdate:(BOOL)arg1;
    -(BOOL)isSelectedPhoneNumberRegistrationSubscriptionContext:(id)arg1;

@end

@interface CTXPCServiceBaseInterface
    - (void)registerForNotifications:(NSArray *)arg1 completion:(void (^)(NSError *))arg2;
    - (void)ping:(void (^)(NSError *))arg1;
    - (void)getDescriptorsForDomain:(long long)arg1 completion:(void (^)(CTServiceDescriptorContainer *, NSError *))arg2;
    - (void)getDualSimCapability:(void (^)(long long, NSError *))arg1;
    - (void)getSimLessContexts:(void (^)(CTXPCSimLessContexts *, NSError *))arg1;
    - (void)getActiveContexts:(void (^)(CTXPCContexts *, NSError *))arg1;
    - (void)getSubscriptionInfo:(void (^)(CTXPCServiceSubscriptionInfo *, NSError *))arg1;
@end

@interface CTXPCServiceSubscriberInterface

- (void)getSIMTrayStatus:(void (^)(NSString *, NSError *))arg1;
- (void)getSIMStatus:(CTXPCServiceSubscriptionContext *)arg1 completion:(void (^)(NSString *, NSError *))arg2;
@end


/* Generated by RuntimeBrowser
   Image: /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
 */

// @interface NSBlock : NSObject <NSCopying>
//
// + (id)alloc;
// // + (id)allocWithZone:(struct _NSZone { }*)arg1;
//
// - (id)copy;
// // - (id)copyWithZone:(struct _NSZone { }*)arg1;
// - (void)invoke;
// - (void)performAfterDelay:(double)arg1;
//
// @end
