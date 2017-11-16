//
//  GTViewController.m
//  GethExplorer
//
//  Created by 书海 on 2017/11/6.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import "GTViewController.h"
#import "MySigner.h"
#import "myTransactOpts.h"


@interface GTViewController ()
@property (weak, nonatomic) IBOutlet UITextField *sourceActIndexTF;
@property (weak, nonatomic) IBOutlet UITextField *receiveActIndexTF;
@property (weak, nonatomic) IBOutlet UITextField *dealNumL;
@property (nonatomic, strong) GethEthereumClient *mEC;
@property (nonatomic, strong) GethKeyStore *mKS;
@property (nonatomic, strong) GethContext *mCTX;
@property (weak, nonatomic) IBOutlet UITextField *sourceActPWDTF;

@property (nonatomic, strong) GethTransactOpts *mOpts;

@property (nonatomic, strong) GethTransaction *tx;
@property (nonatomic, strong) GethTransaction *signedTx;



//@property (nonatomic, strong) myTransactOpts *mOpts;

@end

@implementation GTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self gethInit];
//    [self deployContract];
}

-(void)gethInit{
    
    //1.0  获取文档目录   
    NSString *homeDic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //1.1  拼接文件路径
    NSString *keyStorePath = [homeDic stringByAppendingPathComponent:@"Accounts"];
    //    NSLog(@"keyStorePath = %@",keyStorePath);
    //1.3  Create KeyStore
    self.mKS = GethNewKeyStore(keyStorePath, GethLightScryptN, GethLightScryptP);
    
    NSError *ethError = nil;
    self.mEC = GethNewEthereumClient(@"http://170.16.115.90:9245", &ethError);
    self.mCTX = GethNewContext();
}

- (IBAction)dealBtnClicked:(UIButton *)sender {
    
    NSError *sourceActErr = nil;
    NSError *toActErr = nil;
    GethAccounts *macts = [self.mKS getAccounts];
    GethAccount *sourceAct = nil;
    GethAccount *receiveAct = nil;
    
    if ((0 < self.sourceActIndexTF < macts.size+1) &&(self.sourceActIndexTF.text.length > 0)) {
        sourceAct = [macts get:([self.sourceActIndexTF.text integerValue]-1) error:&sourceActErr];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入正确的发送账户索引"];
        return;
    }
    if ((0 < self.sourceActIndexTF < macts.size+1) && (self.receiveActIndexTF.text.length > 0)) {
        receiveAct = [macts get:([self.receiveActIndexTF.text integerValue]-1) error:&toActErr];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入正确的发送账户索引"];
        return;
    }
    
    //1.7    Create a transaction instance
    int64_t nonceint64 = (int64_t)1;

    NSError *nonceError = nil;
    BOOL getMynonce = [self.mEC getNonceAt:self.mCTX account:sourceAct.getAddress number:(int64_t)-1  nonce:&nonceint64 error:&nonceError];
//
    NSLog(@"nonceint64 = %lld",nonceint64);
    
    NSError *txError = nil;
//    GethTransaction *tx = nil;
    if (self.dealNumL.text.length > 0) {
        
        self.tx = GethNewTransaction(nonceint64, GethNewAddressFromHex(receiveAct.getAddress.getHex, &txError), GethNewBigInt([self.dealNumL.text longLongValue]), GethNewBigInt(100000), GethNewBigInt(10000), nil);
        
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入转出数额"];
        return;
    }
    
    //1.8    Sign a transaction
    NSError *signError = nil;
//    GethTransaction *signedtx = nil;
    if (self.sourceActPWDTF.text.length>0) {
        
        self.signedTx =[self.mKS signTxPassphrase:sourceAct passphrase:self.sourceActPWDTF.text tx:self.tx chainID:GethNewBigInt(13539919) error:&signError];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入正确的起始账户密码"];
        return;
    }
    
    NSLog(@"signError=%@,signedtx==%@",signError,self.signedTx.getHash.getHex);
    
    //1.9    Send a transaction
    NSError *sendError = nil;
    BOOL sendres = [self.mEC sendTransaction:self.mCTX tx:self.signedTx error:&sendError];
    NSLog(@"sendres =%d,sendError = %@",sendres,sendError);
    
//    //1.10    Get a receipt
    NSError *receiptError = nil;
    GethReceipt *receipt = [self.mEC getTransactionReceipt:GethNewContext() hash:self.signedTx.getHash error:&receiptError];
    NSLog(@"receiptError=%@",receiptError.localizedDescription);
//    NSError *logError = nil;
//    GethLogs *mlogs =receipt.getLogs;
//    GethLog *mlog = [mlogs get:mlogs.size-1 error:&logError];
    NSLog(@"gasUsed==%@",receipt.getCumulativeGasUsed.string);
    
    
}

-(void)deployContract{
    [self gethInit];
    NSError *actError = nil;
    GethAccount *act = [[self.mKS getAccounts] get:0 error:&actError];
    
    GethContext *ctx = GethNewContext();
    
    //    2.0 Contract
    //    2.1 Prepare deploy a contract
    
    MySigner *signer = [[MySigner alloc] initWithKeyStore:self.mKS Account:act PassWord:@"1234567890" andChainId:GethNewBigInt(13539919)];
    
    NSLog(@"signer == %@",signer._ref);
    
    int64_t nonceint64 = (int64_t)1;
    NSError *nonceError = nil;
    BOOL getMynonce = [self.mEC getNonceAt:ctx account:act.getAddress number:(int64_t)-1  nonce:&nonceint64 error:&nonceError];
    
    self.mOpts = [[myTransactOpts alloc] initwithContext:ctx from:act.getAddress gasLimit:(int64_t)9000 gasPrice:GethNewBigInt((int64_t)300) signer:signer nonce:nonceint64];
    
//
    //    2.2 Put the code and abi of your contract here
    NSString *byteCode = @"6060604052341561000c57fe5b5b60b61001b6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631003e2d2811460435780636d4ce63c146055575bfe5b3415604a57fe5b60536004356074565b005b3415605c57fe5b60626080565b60408051918252519081900360200190f35b60008054820190555b50565b6000545b905600a165627a7a72305820cea55ffbb44b744ad40c6f202f52d1fcd2d8cc0a1cf29b6b3f93e6a4b1b0f3120029";
    NSString *abi = @"[{\"constant\":false,\"inputs\":[{\"name\":\"i\",\"type\":\"uint256\"}],\"name\":\"add\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"input\":[],\"name\":\"get\",\"outputs\":[{\"name\":\"c\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]";
    
    NSData *byteData = [byteCode dataUsingEncoding:NSUTF8StringEncoding];
    
    //    2.3 Deploy the contract now
    
    GethTransactOpts *tOpts = nil;//[[GethTransactOpts alloc] init];
    NSError *depError = nil;
//    GethBoundContract *mBc = GethDeployContract(tOpts, abi, byteData, self.mEC, GethNewInterfaces(0), &depError);
    GethBoundContract *mB = GethBindContract(act.getAddress, abi, self.mEC, &depError);
    NSError *mbError = nil;
    GethTransaction *mbTx =  [mB transact:tOpts method:byteCode args:GethNewInterfaces(0) error:&mbError]; /**///[mB transfer:tOpts error:&mbError];
    
    NSLog(@"deperror = %@",depError.localizedDescription);
    
    //    2.4 Get value from the contract
    NSError *callMsgError = nil;
    GethCallMsg *callMsg = GethNewCallMsg();
    
    NSError *callMsgAddError = nil;
    GethAddress *callMsgAdd = [[GethAddress alloc] init];
    [callMsgAdd setHex:@"" error:&callMsgAddError];
    
    [callMsg setTo:callMsgAdd];
    
    NSData *callMsgData = [self dataFromHexString:@"6d4ce63c"];
    [callMsg setData:callMsgData];
    
    NSError *callMsgByteError = nil;
    NSData *callMsgData2 = [self.mEC callContract:ctx msg:callMsg number:(int64_t)-1 error:&callMsgByteError];
    
    //    Byte *callMsgByte = (Byte *)[callMsgData2 bytes];
    
    NSLog(@"callMsgByte is %@",[self hexStringFromData:callMsgData]);
    
    //    2.5 Set the value to the contract
    NSData *conData = [self dataFromHexString:@"1003e2d20000000000000000000000000000000000000000000000000000000000000003"];
    GethTransaction *tx2 = GethNewTransaction(nonceint64, act.getAddress, GethNewBigInt(0), GethNewBigInt(4300000), GethNewBigInt(300000),conData);
}

- (IBAction)testBtnClicked:(UIButton *)sender {
    //1.0  获取文档目录   
    NSString *homeDic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //1.1  拼接文件路径
    NSString *nodePath = [homeDic stringByAppendingPathComponent:@"nodeData"];
    NSError *nodeErr = nil;
    GethNode *myNode = GethNewNode(nodePath, GethNewNodeConfig(), &nodeErr);
//    NSLog(@"mynode = %@,nodeError = %@",myNode.getNodeInfo,nodeErr.localizedDescription);//error:Failed to start Ledger hub, disabling: no USB support on iOS
    
    NSError *blockErr = nil;
    GethBlock *mblock = [self.mEC getBlockByNumber:self.mCTX number:(int64_t)-1 error:&blockErr];
    NSLog(@"mblock = %@\n,mblock.getHeader.getBloom.getHex=%@\n,mblock.getNonce=%lld\n,mblock.getNumber=%lld\n,mblock.getGasUsed=%lld\n,mblock.getCoinbase=%@\n,mblock.getHeader.getReceiptHash.getHex=%@\n,mblock.getTransactions.size=%ld",mblock.getHeader.getHash.getHex,mblock.getHeader.getBloom.getHex,mblock.getNonce,mblock.getNumber,mblock.getGasUsed,mblock.getCoinbase.getHex,mblock.getHeader.getReceiptHash.getHex,mblock.getTransactions.size);
    
    NSError *txErr = nil;
    GethTransaction *tx = [mblock.getTransactions get:0 error:&txErr];
    
    NSError *receiptError = nil;
    GethReceipt *receipt = [self.mEC getTransactionReceipt:self.mCTX hash:tx.getHash error:&receiptError];
    NSLog(@"receipt = %@\n,receipt.getGasUsed.string=%@\n,receipt.getContractAddress.getHex=%@",receipt,receipt.getGasUsed.string,receipt.getContractAddress.getHex);
    
    GethChainConfig *mainNetChain = GethMainnetChainConfig();
    
    NSLog(@"mainNetChain.chainID = %lld\n,mainNetChain.homesteadBlock=%lld",mainNetChain.chainID,mainNetChain.homesteadBlock);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSData *)dataFromHexString:(NSString *)hexString {
    const char *chars = [hexString UTF8String];
    NSUInteger i = 0, len = hexString.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

- (NSString *)hexStringFromData:(NSData *)data{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
