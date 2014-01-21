SecuryDemo
==========

Make demo for secure technical on iOS application


There are two things about this demo:
+ Using keychain on app to store and authenticate next time for user. Depend on Apple keychain: 
   See on SDKeychainWwapper class.
+ Store data as security:
   See on SDItemStored class.
   - To test security data:
     You need to turn on passcode and using a tool for Mac to access iOS device via cable like iExplorer 
     while iOS device are locked.

   - We have two methods to test: saveJSONDataToDictNotProtected and saveJSONDataToDict
     + saveJSONDataToDict save data json as secure
     + saveJSONDataToDictNotProtected save data json as non secure
   - Opened one of there function in (void)addAnItemToItemsList:(NSDictionary *)newItem to test
     + If you open saveJSONDataToDict, file items.json will be ono access.
     + if you open saveJSONDataToDictNotProtected, file items.json will be access successfully.
     
     Any issue, please feedback to dang.than@mulodo.com
     
     Regards, 
     
