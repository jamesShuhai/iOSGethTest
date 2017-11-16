//
//  ViewController.m
//  GethExplorer
//
//  Created by 书海 on 2017/11/1.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import "ViewController.h"
#import "MySigner.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UILabel *actNumL;
@property (weak, nonatomic) IBOutlet UITextView *actMsgTextV;
@property (weak, nonatomic) IBOutlet UITextField *exportActIndexTF;
@property (weak, nonatomic) IBOutlet UITextField *deleteActIndexTF;
@property (weak, nonatomic) IBOutlet UITextField *verifyPWDTF;
@property (nonatomic, strong) GethEthereumClient *myEC;
@property (nonatomic, strong) GethKeyStore *mKS;

@property (weak, nonatomic) IBOutlet UITextField *actBalanceIndexTF;

@property (weak, nonatomic) IBOutlet UILabel *actBalanceL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self gethInit];
    
}

-(void)gethInit{
   
    //1.0  获取文档目录   
    NSString *homeDic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //1.1  拼接文件路径
    NSString *keyStorePath = [homeDic stringByAppendingPathComponent:@"Accounts"];
    
    //1.3  Create KeyStore
    self.mKS = GethNewKeyStore(keyStorePath, GethLightScryptN, GethLightScryptP);
    
    NSError *ethError = nil;
    self.myEC = GethNewEthereumClient(@"http://170.16.115.90:9245", &ethError);
    
    NSLog(@"self.mKS = %@,%p",self.mKS._ref,self.mKS._ref);
    GoSeqRef *goRef = (GoSeqRef *)self.myEC._ref;
    NSLog(@"%d%@%d",goRef.incNum,goRef.obj,goRef.refnum);
    
    GethTransactOpts *tops = [[GethTransactOpts alloc] init];
    GoSeqRef *topRef = (GoSeqRef *)tops._ref;
    NSLog(@"%d%@%d",topRef.incNum,topRef.obj,topRef.refnum);
    
    GethAccount *act = [self.mKS.getAccounts get:0 error:&ethError];
    MySigner *signer = [[MySigner alloc] initWithKeyStore:self.mKS Account:act PassWord:@"1234567890" andChainId:GethNewBigInt(13539919)];
    GoSeqRef *signRef = (GoSeqRef *)signer._ref;
    NSLog(@"%d%@%d",signRef.incNum,signRef.obj,signRef.refnum);
//    MySigner *
//    [tops setFrom:act.getAddress];//error:go_seq_go_to_refnum on objective-c objects is not permitted
//
//
//    GethAccount *act = [self.mKS.getAccounts get:1 error:&ethError];
//    GethTransaction *tx = GethNewTransaction((int64_t)1, GethNewAddressFromHex(act.getAddress.getHex, &ethError), GethNewBigInt(1000000000), GethNewBigInt(100000), GethNewBigInt(10000), nil);
    
//    GoSeqRef *goRef = [[GoSeqRef alloc] init];
//
//    GoSeqRef *txRef = [[GoSeqRef alloc] initWithRefnum:(int32_t)-28 obj:nil];
//    GethTransactOpts *opts = [[GethTransactOpts alloc] initWithRef:txRef
//                              ];
//    [opts setNonce:(int64_t)12];
//    NSLog(@"%lld",opts.getNonce);
    
}

//-(GethKeyStore *)getGethKeyStore{
//    return self.mKS;
//}

- (IBAction)createAccountBtnClicked:(UIButton *)sender {
    
    //1.4    Create Account
    GethAccounts *listAcc = self.mKS.getAccounts;
    
    NSString *pwd = self.pwdTF.text;
    NSError *accError = nil;
    GethAccount *act = nil;
    if (listAcc.size>5) {
        [SVProgressHUD showInfoWithStatus:@"您最多只能创建5个账户！"];
    }else {
        if (pwd.length<6) {
            [SVProgressHUD showInfoWithStatus:@"密码长度不小于6位数！"];
            return;
        }else{
            act = [self.mKS newAccount:pwd error:&accError];
        }
        
    }
}
- (IBAction)reviewAccountNumberBtnClicked:(UIButton *)sender {
    
    //1.4    Create Account
    GethAccounts *listAcc = self.mKS.getAccounts;
    self.actNumL.text = [NSString stringWithFormat:@"%ld",listAcc.size];
    
    GoSeqRef *goRef = (GoSeqRef *)listAcc._ref;
    NSLog(@"%d%@%d",goRef.incNum,goRef.obj,goRef.refnum);
    
}


- (IBAction)exportAccountBtnClicked:(UIButton *)sender {
    
    NSInteger actIndex = self.exportActIndexTF.text.integerValue -1;
    
    //1.4    Create Account
    GethAccounts *listAcc = self.mKS.getAccounts;
    
    if (listAcc.size > actIndex) {
        
        if ((actIndex < 0) && (self.exportActIndexTF.text.length <= 0)) {
            [SVProgressHUD showInfoWithStatus:@"请输入正确的索引值和密码"];
        }else{
            
            
            NSError *accError = nil;
            
            GethAccount *act = [listAcc get:actIndex error:&accError];
            
            NSError *ethError = nil;
            GethEthereumClient *ec = GethNewEthereumClient(@"http://170.16.115.90:9245", &ethError);
            
            
            NSData * actdata = [self.mKS exportKey:act passphrase:self.verifyPWDTF.text newPassphrase:self.verifyPWDTF.text error:&ethError];
            if (ethError!=nil) {
                [SVProgressHUD showInfoWithStatus:ethError.localizedDescription];
                return;
            }else{
                
                NSDictionary *actDict = [NSJSONSerialization JSONObjectWithData:actdata options:NSJSONReadingMutableLeaves error:nil];
                
                self.actMsgTextV.text = actDict.mj_JSONString;
            }
            
            
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"您输入的索引值超出目标范围！"];
    }
    
}


- (IBAction)deleteActBtnClicked:(UIButton *)sender {
    NSInteger actIndex = self.deleteActIndexTF.text.integerValue -1;
    
    //1.4    Create Account
    GethAccounts *listAcc = self.mKS.getAccounts;
    
    if (listAcc.size > actIndex) {
        
        if (actIndex<0) {
            [SVProgressHUD showInfoWithStatus:@"请输入正确的索引值"];
        }else{
            
            NSError *accError = nil;
            GethAccount *act = [listAcc get:actIndex error:&accError];
            
            NSError *delError = nil;
            NSError *ecError = nil;
            GethEthereumClient *ec = GethNewEthereumClient(@"http://170.16.115.90:9245", &ecError);
            
            BOOL isDel = [self.mKS deleteAccount:act passphrase:@"" error:&delError];
            
            if (isDel == NO) {
                [SVProgressHUD showInfoWithStatus:@"账户删除失败！"];
            }else{
                [SVProgressHUD showInfoWithStatus:@"账户删除成功！"];

            }
            
        }
    }
    
}
- (IBAction)reviewAccountBalanceBtnClicked:(id)sender {
    
    //1.6    Create a context
    GethContext *ctx = GethNewContext();
    NSError *addError = nil;
    NSError *nonceError = nil;
    NSError *accError = nil;
    
    //1.4    Create Account
    GethAccounts *listAcc = self.mKS.getAccounts;
    GethAccount *act = nil;
    
    NSInteger actIndex = self.actBalanceIndexTF.text.integerValue -1;
    if (0 < actIndex < (listAcc.size+1)) {
        
        act = [listAcc get:actIndex error:&accError];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入正确的账户索引值！"];
    }
    
    GethBigInt *count = [self.myEC getBalanceAt:ctx account:act.getAddress number:(int64_t)-1 error:&nonceError];
    
    self.actBalanceL.text = count.string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)gethExplorer{
    
    //1.0  获取文档目录   
    NSString *homeDic = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //1.1  拼接文件路径
    NSString *keyStorePath = [homeDic stringByAppendingPathComponent:@"Accounts"];
    NSLog(@"keyStorePath = %@",keyStorePath);
    
    //1.3  Create KeyStore
    GethKeyStore *ks = GethNewKeyStore(keyStorePath, GethLightScryptN, GethLightScryptP);
    
    //1.4    Create Account
    GethAccounts *listAcc = ks.getAccounts;
    
    NSString *pwd = @"1234567890";
    NSError *accError = nil;
    GethAccount *act = nil;
    if (listAcc.size>0) {
        act = [listAcc get:0 error:&accError];
    }else{
        act = [ks newAccount:pwd error:&accError];
        
    }
    NSLog(@"address==%@",act.getAddress.getHex);
    //1.5    Connect to a ethereum node
    NSError *ethError = nil;
    GethEthereumClient *ec = GethNewEthereumClient(@"http://170.16.115.90:9245", &ethError);
    
    
    NSData * actdata = [ks exportKey:act passphrase:@"1234567890" newPassphrase:@"1234567890" error:&ethError];

    
    NSDictionary *actDict = [NSJSONSerialization JSONObjectWithData:actdata options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"actDict= %@",actDict);
    
    //1.6    Create a context
    GethContext *ctx = GethNewContext();
    NSError *addError = nil;
    NSError *nonceError = nil;
    GethBlock *mblock = [ec getBlockByNumber:ctx number:(int64_t)-1 error:&addError];
    NSLog(@"mblock = %@",mblock.getHeader.getHash.getHex);
    int64_t nonceint64 = (int64_t)1;
    //1.7    Create a transaction instance
    
    GethBigInt *count = [ec getBalanceAt:ctx account:act.getAddress number:(int64_t)-1 error:&nonceError];
    NSLog(@"count == %@",count.string);
    BOOL getMynonce = [ec getNonceAt:ctx account:act.getAddress number:(int64_t)-1  nonce:&nonceint64 error:&nonceError];
    
    NSLog(@"nonceint64 = %lld",nonceint64);
    GethTransaction *tx = GethNewTransaction(nonceint64, GethNewAddressFromHex(act.getAddress.getHex, &addError), GethNewBigInt(10000000), GethNewBigInt(4300000), GethNewBigInt(300000), nil);
    
    //1.8    Sign a transaction
    NSError *signError = nil;
    GethTransaction *signedtx =[ks signTxPassphrase:act passphrase:pwd tx:tx chainID:GethNewBigInt(13539919) error:&signError];
    NSLog(@"%@,%@",signError,signedtx.getHash.getHex);
    //1.9    Send a transaction
    NSError *sendError = nil;
    BOOL sendres = [ec sendTransaction:ctx tx:signedtx error:&sendError];
    NSLog(@"sendError =%d,error = %@",sendres,sendError);
    //1.10    Get a receipt
    GethHash *signedHash = [[GethHash alloc] initWithRef:signedtx._ref];
    NSError *receiptError = nil;
    [ec getTransactionReceipt:ctx hash:signedHash error:&receiptError];
    
    //    2.0 Contract
    //    2.1 Prepare deploy a contract
    GethTransactOpts *tops = [[GethTransactOpts alloc] init];
    [tops setContext:ctx];
    [tops setFrom:act.getAddress];
    [tops setGasLimit:(int64_t)900000];
    [tops setGasPrice:GethNewBigInt((int64_t)30000)];
    
    GethSigner *signer = [[GethSigner alloc] initWithRef:act._ref];
    [tops setSigner:signer];
    [tops setNonce:nonceint64];
    
    //    2.2 Put the code and abi of your contract here
    NSString *byteCode = @"6060604052341561000c57fe5b5b60b38061001b6000396000f300606060405263ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416631003e2d2811460435780636d4ce63c146055575bfe5b3415604a57fe5b60536004356074565b005b3415605c57fe5b60626080565b60408051918252519081900360200190f35b60008054820190555b50565b6000545b905600a165627a7a72305820cea55ffbb44b744ad40c6f202f52d1fcd2d8cc0a1cf29b6b3f93e6a4b1b0f3120029";
    NSString *abi = @"[{\"constant\":false,\"inputs\":[{\"name\":\"i\",\"type\":\"uint256\"}],\"name\":\"add\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"get\",\"outputs\":[{\"name\":\"c\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]";
    
    //    2.3 Deploy the contract now
    NSError *depError = nil;
    GethDeployContract(tops, abi, byteCode, ec, GethNewInterfaces(0), &depError);
    
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
    NSData *callMsgData2 = [ec callContract:ctx msg:callMsg number:(int64_t)-1 error:&callMsgByteError];
    
//    Byte *callMsgByte = (Byte *)[callMsgData2 bytes];
    
    NSLog(@"callMsgByte is %@",[self hexStringFromData:callMsgData]);
    
    //    2.5 Set the value to the contract
    NSData *conData = [self dataFromHexString:@"1003e2d20000000000000000000000000000000000000000000000000000000000000003"];
    GethTransaction *tx2 = GethNewTransaction(nonceint64, act.getAddress, GethNewBigInt(0), GethNewBigInt(4300000), GethNewBigInt(300000),conData);
    
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
