#iOSGethTest
## 0 Setup environment
use cocoapods setup 'Geth',In your app Podfile, add the line below
```gradle
pod 'Geth', '~> 1.5.4'
```
## 1 KeyStore and Transaction
### 1.1 Create KeyStore
 ```Object-C
 GethKeyStore *mKS = GethNewKeyStore(keyStorePath, GethLightScryptN, GethLightScryptP);
```
### 1.2 Create Account
```Object-C
NSString *pwd = "123456";
GethAccount *act = [mKS newAccount:pwd error:&accError];
```
### 1.3 Connect to a ethereum node
```Object-C
GethEthereumClient *myEC = GethNewEthereumClient(@"http://127.0.0.1:8545", &ethError);//Your ethereum address
```
### 1.4 Create a context
```Object-C
GethContext *ctx = GethNewContext();//Create a context
```
### 1.5 Create a transaction instance
```Object-C
NSError *txError = nil;;
GethTransaction *tx = GethNewTransaction(nonceint64, GethNewAddressFromHex(@"0x218FeeF49FB0582c7bB739ab0DEf617c651ec8c3", &txError), GethNewBigInt(1000000000), GethNewBigInt(100000), GethNewBigInt(10000), nil);
```
### 1.6 Sign a transaction
```Object-C
NSError *signError = null;
GethTransaction *signedtx =[mKS signTxPassphrase:sourceAct passphrase:@"123456" tx:tx chainID:GethNewBigInt(13539919)/*Your network ID*/ error:&signError];

```
### 1.7 Send a transaction
```Object-C
NSError *sendError = nil;
BOOL sendres = [self.myEC sendTransaction:ctx tx:self.signedTx error:&sendError];

```
Enjoy it!
