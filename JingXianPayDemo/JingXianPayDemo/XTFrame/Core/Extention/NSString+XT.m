//
//  NSString+XT.m
//  FingerTipEarn
//
//  Created by dengtao on 2017/4/12.
//  Copyright © 2017年 dengtao. All rights reserved.
//

#import "NSString+XT.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
//引入IOS自带密码库
#include <CommonCrypto/CommonCryptor.h>

@implementation NSString (XT)


+ (NSString *)newUUID{
    CFUUIDRef uuidRef = CFUUIDCreate( nil );
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString( nil, uuidRef )) ;
    CFRelease(uuidRef);
    return [uuidString lowercaseString];
}

+ (NSString *)mechineID{
    return [[UIDevice currentDevice] uniqueGlobalIdentifier];
}

- (NSString *)md5Digest{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSString *)sha1Digest{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

#pragma mark - DES加密


- (CGSize)sizeWithFont:(UIFont *)font byWidth:(CGFloat)width{
    
    return [self sizeWithFont:font
            constrainedToSize:CGSizeMake(width, 999999.0f)
                lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)getSpaceLabelHeightWithFont:(UIFont *)font withWidth:(CGFloat)width{
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 6;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle
                          };
    
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, 999999.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    return size;
}

- (CGSize)sizeWithFont:(UIFont *)font byHeight:(CGFloat)height{
    return [self sizeWithFont:font
            constrainedToSize:CGSizeMake(999999.0f, height)
                lineBreakMode:NSLineBreakByWordWrapping];
}



- (BOOL)isMatch:(NSString *)regex{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

- (BOOL)isHaveString:(NSString *)string{
    NSRange range = [self rangeOfString:string];
    return range.length > 0;
}

static NSDateFormatter *dateFormatter = nil;

- (NSDate *)dateWithFormate:(NSString *)formate{
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:formate];
    return [dateFormatter dateFromString:self];
}

- (NSString *)getBrithdayFromIdCard{
    
    BOOL isMonth = NO;
    BOOL isDay = NO;
    NSString *brithday = nil;
    
    if ([self isIDCard]) {//isMatch:Regex_IDCard
        //511521 1988 10 10 2222
        if (self.length == 18) {
            
            brithday = [self substringWithRange:NSMakeRange(6, 8)];
        }
        if (self.length == 15) {
            
            brithday = [NSString stringWithFormat:@"%@%@",@"19",[self substringWithRange:NSMakeRange(6, 6)]];
        }
        
        NSString *year = [brithday substringToIndex:4];
        NSString *month = [brithday substringWithRange:NSMakeRange(4, 2)];
        if ([month integerValue] > 0 && [month integerValue] <=12) {
            
            isMonth = YES;
        }
        
        NSString *day = [brithday substringFromIndex:6];
        NSInteger countOfMonth = [self getDayCountWithYear:[year integerValue] month:[month integerValue]];
        if ([day integerValue] > 0 && [day integerValue] <= countOfMonth) {
            
            isDay = YES;
        }
        brithday = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    }
    if (isMonth && isDay) {
        
        return brithday;
    }else{
        
        return nil;
    }
}

- (NSInteger)getDayCountWithYear:(NSInteger)year month:(NSInteger )month{
    
    NSInteger day = 30;
    BOOL isLeadYear = NO;
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        //闰年
        isLeadYear = YES;
    }
    switch (month) {
        case 1:
            day = 31;
            break;
        case 2:
            if (isLeadYear) {
                
                day = 29;
            }else{
                
                day = 28;
            }
            break;
        case 3:
            day = 31;
            break;
        case 4:
            day = 30;
            break;
        case 5:
            day = 31;
            break;
        case 6:
            day = 30;
            break;
        case 7:
            day = 31;
            break;
        case 8:
            day = 31;
            break;
        case 9:
            day = 30;
            break;
        case 10:
            day = 31;
            break;
        case 11:
            day = 30;
            break;
        case 12:
            day = 31;
            break;
            
        default:
            break;
    }
    return day;
}

- (NSInteger)getAgeWithFromIdCard{
    
    NSInteger age = 0;
    NSString *brithday = nil;
    if (self.length == 18) {
        
        brithday = [self substringWithRange:NSMakeRange(6, 8)];
    }
    if (self.length == 15) {
        
        brithday = [NSString stringWithFormat:@"%@%@",@"19",[self substringWithRange:NSMakeRange(6, 6)]];
    }
    
    NSString *year = [brithday substringWithRange:NSMakeRange(0, 4)];
    NSString *now = [[NSDate stringFromDateCompare:[NSDate date]] substringToIndex:4];
    
    age = [now integerValue] - [year integerValue];
    return age;
}

- (BOOL)isIDCard{
    
    //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex_IDCard];
    //    if ([regextestmobile evaluateWithObject:self] == YES)
    //    {
    //        return YES;
    //    }
    //    else
    //    {
    //        return NO;
    //    }
    
    /*************************************************************************************
     居民身份证号码:百度百科
     
     一、结构和形式
     　　1．号码的结构
     　　公民身份号码是特征组合码，由十七位数字本体码和一位校验码组成。排列顺序从左至右依次为：六位数字地址码，八位数字出生日期码，三位数字顺序码和一位数字校验码。
     　　2．地址码
     　　表示编码对象常住户口所在县（市、旗、区）的行政区划代码，按GB/T2260的规定执行。
     　　3．出生日期码
     　　表示编码对象出生的年、月、日，按GB/T7408的规定执行，年、月、日代码之间不用分隔符。
     　　4．顺序码
     　　表示在同一地址码所标识的区域范围内，对同年、同月、同日出生的人编定的顺序号，顺序码的奇数分配给男性，偶数分配给女性。
     　　5．校验码
     　　根据前面十七位数字码，按照ISO 7064:1983.MOD 11-2校验码计算出来的检验码。
     
     二、地址码
     
     （身份证号码前六位）表示编码对象常住户口所在县（市、镇、区）的行政区划代码。
     北京市|110000，天津市|120000，河北省|130000，山西省|140000，内蒙古自治区|150000，辽宁省|210000，吉林省|220000，
     黑龙江省|230000，上海市|310000，江苏省|320000，浙江省|330000，安徽省|340000，福建省|350000，江西省|360000，山东省|370000，
     河南省|410000，湖北省|420000，湖南省|430000，广东省|440000，广西壮族自治区|450000，海南省|460000，重庆市|500000，
     四川省|510000，贵州省|520000，云南省|530000，西藏自治区|540000，陕西省|610000，甘肃省|620000，青海省|630000，
     宁夏回族自治区|640000，新疆维吾尔自治区|650000，台湾省（886)|710000,香港特别行政区（852)|810000，澳门特别行政区（853)|820000
     
     大陆居民身份证号码中的地址码的数字编码规则为：
     第一、二位表示省（自治区、直辖市、特别行政区）。
     第三、四位表示市（地级市、自治州、盟及国家直辖市所属市辖区和县的汇总码）。其中，01-20，51-70表示省直辖市；21-50表示地区（自治州、盟）。
     第五、六位表示县（市辖区、县级市、旗）。01-18表示市辖区或地区（自治州、盟）辖县级市；21-80表示县（旗）；81-99表示省直辖县级市。
     
     
     三、生日期码
     
     （身份证号码第七位到第十四位）表示编码对象出生的年、月、日，其中年份用四位数字表示，年、月、日之间不用分隔符。例如：1981年05月11日就用19810511表示。
     ps:15位身份证号 出生的年 没有19或20   没有最后一位校验码
     四、顺序码
     
     （身份证号码第十五位到十七位）地址码所标识的区域范围内，对同年、月、日出生的人员编定的顺序号。其中第十七位奇数分给男性，偶数分给女性。
     五、校验码
     
     作为尾号的校验码，是由号码编制单位按统一的公式计算出来的，如果某人的尾号是0-9，都不会出现X，但如果尾号是10，那么就得用X来代替，因为如果用10做尾号，那么此人的身份证就变成了19位，而19位的号码违反了国家标准，并且中国的计算机应用系统也不承认19位的身份证号码。Ⅹ是罗马数字的10，用X来代替10，可以保证公民的身份证符合国家标准。
     
     六、计算方法
     
     1、将前面的身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。
     2、将这17位数字和系数相乘的结果相加。
     3、用加出来和除以11，看余数是多少？
     4、余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字。其分别对应的最后一位身份证的号码为1－0－X －9－8－7－6－5－4－3－2。
     5、通过上面得知如果余数是3，就会在身份证的第18位数字上出现的是9。如果对应的数字是2，身份证的最后一位号码就是罗马数字x。
     例如：某男性的身份证号码为【53010219200508011x】， 我们看看这个身份证是不是合法的身份证。
     首先我们得出前17位的乘积和【(5*7)+(3*9)+(0*10)+(1*5)+(0*8)+(2*4)+(1*2)+(9*1)+(2*6)+(0*3)+(0*7)+(5*9)+(0*10)+(8*5)+(0*8)+(1*4)+(1*2)】是189，然后用189除以11得出的结果是189/11=17----2，也就是说其余数是2。最后通过对应规则就可以知道余数2对应的检验码是X。所以，可以判定这是一个正确的身份证号码。
     
     *******************************************************************************************/
    NSString *cardId = self;
    if (cardId.length != 15 && cardId.length != 18) {
        
        return NO;
    }else{
        
        if (cardId.length == 15) {
            
            cardId = [NSString stringWithFormat:@"%@%@%@",[cardId substringToIndex:6],@"19",[cardId substringFromIndex:6]];
        }
        
        NSString *province = [cardId substringToIndex:2];
        NSString *city = [cardId substringWithRange:NSMakeRange(2, 2)];
        NSString *country = [cardId substringWithRange:NSMakeRange(4, 2)];
        
        //第一、二位表示省
        NSArray *province_id = @[@"11",@"12",@"13",@"14",@"15",
                                 @"21",@"22",@"23",@"31",@"32",
                                 @"33",@"34",@"35",@"36",@"37",
                                 @"41",@"42",@"43",@"44",@"45",
                                 @"46",@"50",@"51",@"52",@"53",
                                 @"54",@"55",@"60",@"61",@"62",
                                 @"63",@"64",@"65",@"71",@"82"];
        BOOL isProvince = NO;
        for (NSString *str in province_id) {
            
            if ([province isEqualToString:str]) {
                
                isProvince = YES;
                break;
            }
        }
        if (!isProvince) {
            
            return NO;
        }
        //第三、四位表示市
        
        //第五、六位表示县
        
        //        NSString* plistPath=[[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
        //        NSDictionary *plistDic=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
        //
        //第七位到第十四位 生日
        NSString *year = [cardId substringWithRange:NSMakeRange(6, 4)];
        NSString *month = [cardId substringWithRange:NSMakeRange(10, 2)];
        NSString *day = [cardId substringWithRange:NSMakeRange(12, 2)];
        
        //年
        if ([[year substringToIndex:2] isEqualToString:@"19"] ||
            [[year substringToIndex:2] isEqualToString:@"20"]) {
            
            
            NSString *nowYear = [[NSDate stringFromDateCompare:[NSDate date]] substringToIndex:4];
            if ([year integerValue] <= [nowYear integerValue]) {
                
                //合法的年份
                
            }else{
                
                return NO;
            }
            
            
        }else{
            
            return NO;
        }
        
        
        //月
        if ([month integerValue] > 0 && [month integerValue] <=12) {
            
            //合法的月份
        }else{
            
            return NO;
        }
        
        NSInteger countOfMonth = [self getDayCountWithYear:[year integerValue] month:[month integerValue]];
        if ([day integerValue] > 0 && [day integerValue] <= countOfMonth) {
            
            //合法的日期
        }else{
            
            return NO;
        }
        
        /*
         计算方法
         
         1、将前面的身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。
         2、将这17位数字和系数相乘的结果相加。
         3、用加出来和除以11，看余数是多少？
         4、余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字。其分别对应的最后一位身份证的号码为1－0－X －9－8－7－6－5－4－3－2。
         5、通过上面得知如果余数是3，就会在身份证的第18位数字上出现的是9。如果对应的数字是2，身份证的最后一位号码就是罗马数字x。
         例如：某男性的身份证号码为【53010219200508011x】， 我们看看这个身份证是不是合法的身份证。
         首先我们得出前17位的乘积和【(5*7)+(3*9)+(0*10)+(1*5)+(0*8)+(2*4)+(1*2)+(9*1)+(2*6)+(0*3)+(0*7)+(5*9)+(0*10)+(8*5)+(0*8)+(1*4)+(1*2)】是189，然后用189除以11得出的结果是189/11=17----2，也就是说其余数是2。最后通过对应规则就可以知道余数2对应的检验码是X。所以，可以判定这是一个正确的身份证号码。
         */
        NSString *lastString = nil;
        if(cardId.length == 18){
            
            lastString = [cardId substringFromIndex:17];
        }
        if (cardId.length == 17) {
            
            //15--(年19)-->17  没有第十八位校验码
            return YES;
        }
        
        NSInteger sum = 0;
        NSArray *checkArry = @[@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",
                               @"7",@"9",@"10",@"5",@"8",@"4",@"2"];
        for (NSInteger i = 0; i < 17; i ++) {
            
            NSString *char_id = [cardId substringWithRange:NSMakeRange(i, 1)];
            sum += [char_id integerValue] * [checkArry[i] integerValue];
        }
        
        NSInteger result = sum % 11;
        
        switch (result) {
            case 0:
            {
                if (cardId.length == 18) {
                    
                    if ([lastString isEqualToString:@"1"]) {
                        
                        return YES;
                    }else{
                        
                        return NO;
                    }
                }else{
                    
                    //15-->18 最后一位校验码
                    
                }
                
            }
                break;
            case 1:
            {
                if ([lastString isEqualToString:@"0"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 2:
            {
                if ([lastString isEqualToString:@"x"] || [lastString isEqualToString:@"X"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 3:
            {
                if ([lastString isEqualToString:@"9"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 4:
            {
                if ([lastString isEqualToString:@"8"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 5:
            {
                if ([lastString isEqualToString:@"7"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 6:
            {
                if ([lastString isEqualToString:@"6"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 7:
            {
                if ([lastString isEqualToString:@"5"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 8:
            {
                if ([lastString isEqualToString:@"4"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 9:
            {
                if ([lastString isEqualToString:@"3"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
            case 10:
            {
                if ([lastString isEqualToString:@"2"]) {
                    
                    return YES;
                }else{
                    
                    return NO;
                }
            }
                break;
                
            default:
                break;
        }
    }
    return YES;
}

+ (NSString *)hmacSha1:(NSString*)key text:(NSString*)text
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    return hash;
}

- (NSString *)transformToPinyin
{
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, false);
    return mutableString;
}

//校验密码，字母或数字
+ (BOOL)isPassword:(NSString *)password
{
    NSInteger length = [password length];
    NSString *PW = @"^[A-Za-z0-9]+$";
    NSPredicate *registPassword = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PW];
    if ([registPassword evaluateWithObject:password] == YES && length >= 6 && length <= 20) {
        return YES;
    }else{
        return NO;
    }
}

//正则表达式校验数据
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,183,187,188,178，14[0-9],15[0-9]
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0-9]|7[0-9]|8[23478]|4[0-9]|78)\\d)\\d{7}$";
    
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,145,176
     17         */
    NSString * CU = @"^1(3[0-2]|4[5]|5[256]|8[56]|76)\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,181,177
     22         */
    NSString * CT = @"^1((33|53|77|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }else{
        return NO;
    }
    //校验密码
}

+ (NSMutableString *)notFullyDisplayBankNumberStringWith:(NSString *)str
{
    NSMutableString *temStr = [[NSMutableString alloc] initWithCapacity:10];
    [temStr appendString:[str substringWithRange:NSMakeRange(0, 6)]];
    [temStr appendString:@"******"];
    [temStr appendString:[str substringWithRange:NSMakeRange([str length]-4, 4)]];
    return temStr;
}

- (NSMutableAttributedString *)multipleColorWithLabel:(NSString *)string color:(UIColor *)color length:(NSInteger)length
{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:string];
    [AttributedStr addAttribute:NSForegroundColorAttributeName  value:color range:NSMakeRange(0, length)];
    
    return AttributedStr;
}

//判断是否输入某个字符
- (BOOL)haveStringWithChar:(NSString *)string{
    
    if ([self rangeOfString:string].location == NSNotFound) {
        return  NO;
    }else{
        return YES;
    }
}

// url的参数字符串转字典
- (NSDictionary *)urlQueryStringToDictionary
{
    if ([self rangeOfString:@"="].location != NSNotFound) {
        NSArray *paramsArr = [self componentsSeparatedByString:@"&"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        for (NSString *param in paramsArr) {
            NSArray *paramArr = [param componentsSeparatedByString:@"="];
            if (paramArr.count == 2) {
                [dic setObject:paramArr[1] forKey:paramArr[0]];
            }
        }
        
        return dic;
    } else {
        return  nil;
    }
}
- (NSString *)toUrlQueryStringWithDictionary:(NSDictionary *)dic{
    
    // NOTE: 排序，得出最终请求字串
    NSArray* sortedKeyArray = [[dic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (NSString* key in sortedKeyArray) {
        NSString* orderItem = [self orderItemWithKey:key andValue:[dic objectForKey:key] encoded:YES];
        if (orderItem.length > 0) {
            [tmpArray addObject:orderItem];
        }
    }
    return [tmpArray componentsJoinedByString:@"&"];
}

- (NSString*)orderItemWithKey:(NSString*)key andValue:(NSString*)value encoded:(BOOL)bEncoded
{
    if (key.length > 0 && value.length > 0) {
        if (bEncoded) {
            value = [self encodeValue:value];
        }
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }
    return nil;
}

- (NSString*)encodeValue:(NSString*)value
{
    NSString* encodedValue = value;
    if (value.length > 0) {
        encodedValue = (__bridge_transfer  NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)value, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    }
    return encodedValue;
}


+ (NSString *)timeStampTransformatToDate:(NSInteger )timeStamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    if (timeStamp == 0) {
        return @"0";
    }
    return confromTimespStr;
}

+ (NSMutableAttributedString *)multipleColorWithPlaceholder:(NSString *)string length:(NSUInteger)length leftColor:(UIColor *)color
{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:string];
    [AttributedStr addAttribute:NSForegroundColorAttributeName  value:color range:NSMakeRange(0, length)];
    
    return AttributedStr;
}



+ (NSString *)handleSpaceAndEnterElementWithString:(NSString *)sourceStr

{
    NSString *realSre = [sourceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *realSre1 = [realSre stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *realSre2 = [realSre1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *realSre3 = [realSre2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *realSre4 = [realSre3 stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    NSString *realSre5 = [realSre4 stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    NSArray *array = [realSre5 componentsSeparatedByString:@","];
    
    return [array objectAtIndex:0];
    
}

+ (NSString *)handleSpaceAndEnter:(NSString *)sourceStr

{
    NSString *realSre = [sourceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *realSre2 = [realSre stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *realSre3 = [realSre2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *array = [realSre3 componentsSeparatedByString:@","];
    
    return [array objectAtIndex:0];
    
}

#pragma mark - 银行信息
- (BOOL)checkBankCardNo{
    
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[self length];
    int lastNum = [[self substringFromIndex:cardNoLength-1] intValue];
    
    NSString *card = [self substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [card substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

+ (NSString *)getBankName:(NSString*) idCard{
    
    //path 读取plist
//    NSArray *paths =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path =  [paths    objectAtIndex:0];
//    NSString *filename = [path stringByAppendingPathComponent:@"bank.plist"];   //获取路径
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"plist"];
    
    NSArray *data = [NSArray arrayWithContentsOfFile:filename];
    if (!data) {

        return @"";
//        [NSString wirtePlistWithBankInfo];
//        [NSString getBankName:idCard];
    }else{
        
        //BIN号
        NSArray *bankBin = data[0][@"bankBin"];
        //"发卡行.卡种名称",
        NSArray *bankName = data[1][@"bankName"];
        int index = -1;
        
        if(idCard==nil || idCard.length<16 || idCard.length>19){
            
            return @"";
        }
        //6位Bin号
        NSString* cardbin_6 = [idCard substringWithRange:NSMakeRange(0, 6)];
        
        for (int i = 0; i < bankBin.count; i++) {
            
            if ([cardbin_6 isEqualToString:bankBin[i]]) {
                
                index = i;
            }
        }
        if (index != -1) {
            
            return bankName[index];
        }
        //8位Bin号
        NSString* cardbin_8 = [idCard substringWithRange:NSMakeRange(0, 8)];
        
        for (int i = 0; i < bankBin.count; i++) {
            
            if ([cardbin_8 isEqualToString:bankBin[i]]) {
                
                index = i;
            }
        }
        if (index != -1) {
            
            return bankName[index];
        }
    }
    return @"";
}

/////////

+ (NSString *)getBankNameByBin:(char *)numbers count:(int)nCount {
    NSUInteger len = sizeof(strBankBinArray)/sizeof(strBankBinArray[0]) ;
    NSUInteger slen, dlen;
    int i, j;
    int bEqual;
    char code[32];
    NSString *bankName = nil;
    
    for(i = 0, dlen = 0; i < nCount; ++i) {
        if(numbers[i] == ' ') continue;
        code[dlen++] = numbers[i];
    }
    
    bankName = nil;
    for(i = 0; i < len; i+= 2) {
        const char *ch = strBankBinArray[i];
        slen = strlen(strBankBinArray[i]);
        if(dlen < slen) continue;
        
        bEqual = 1;
        for(j = 0; j < slen; ++j) {
            if(ch[j] != code[j]){ bEqual = 0; break; }
        }
        if(bEqual == 1) {
            int stdCardNumCount = BankBinArrayCount[i/2];
            if(stdCardNumCount == 0 || stdCardNumCount == dlen)
            bankName = [NSString stringWithUTF8String:strBankBinArray[i+1]];
            break;
        }
    }
    return bankName;
}


static  int  BankBinArrayCount[] = {
    0, 0, 0, 0, 0, 19, 16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 0, 16, 16, 0, 0, 16, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 16, 16, 0, 16, 16, 16, 0, 16, 0, 16, 0, 0, 16, 16, 0, 0, 0, 0, 0, 16, 16, 17, 16,
    16, 16, 16, 0, 0, 16, 0, 16, 0, 16, 0, 0, 16, 0, 16, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 0, 16,
    0, 0, 0, 0, 16, 0, 16, 16, 0, 16, 16, 0, 0, 0, 0, 16, 16, 0, 0, 0, 0, 0, 0, 16, 0, 0, 16, 0, 0,
    0, 0, 19, 0, 16, 16, 0, 0, 16, 0, 16, 0, 0, 0, 16, 16, 16, 16, 0, 0, 0, 16, 16, 0, 16, 16, 16,
    19, 0, 16, 0, 16, 16, 0, 0, 16, 0, 0, 16, 0, 16, 0, 16, 16, 0, 0, 0, 0, 0, 16, 0, 16, 16, 16,
    0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 16, 16, 0, 16, 16, 0, 16, 16, 0, 0, 16, 0, 0, 0, 16,
    16, 16, 0, 16, 16, 0, 0, 0, 16, 16, 16, 16, 16, 16, 0, 0, 16, 16, 0, 16, 16, 0, 16, 0, 16, 16,
    16, 16, 0, 16, 0, 0, 16, 16, 0, 0, 0, 0, 0, 16, 0, 0, 16, 0, 0, 16, 16, 0, 16, 16, 16, 0, 16,
    16, 16, 16, 16, 16, 0, 16, 16, 0, 16, 16, 16, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 16, 16, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 18, 19, 17, 16, 16, 18, 16, 18, 0, 0, 0, 19, 17, 0, 18, 0, 16, 18, 18, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 18, 0, 0, 16, 16, 0, 0, 16, 0, 0, 0, 19, 19, 0, 0, 19, 0, 0, 0, 19, 0, 16, 0, 16, 0,
    0, 19, 0, 0, 19, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 16, 16,
    0, 16, 0, 0, 0, 0, 19, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 19, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 19, 0, 0,
    0, 19, 19, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 19, 0, 0, 0, 0, 19, 0, 19, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 18, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 18, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 16, 18, 16, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 19, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 16, 19, 0, 19, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 19, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 19, 0, 0, 0, 19, 18, 0, 19, 0, 0, 16, 19, 0, 0, 0, 16, 19,
    16, 16, 19, 0, 0, 0, 19, 19, 19, 19, 16, 16, 16, 0, 0, 0, 0, 16, 0, 0, 16, 0, 16, 19, 0, 0, 0, 19, 16, 0, 0, 0, 19,
    19, 19, 0, 0, 0, 0, 19, 19, 0, 16, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 16, 0, 0, 16, 16, 0, 16, 0, 16,
    0, 0, 16, 0, 0, 16, 16, 0, 0, 16, 0, 0, 0, 19, 0, 19, 0, 0, 0, 0, 0, 0, 18, 0, 0, 0, 16, 0, 16, 0, 18, 19, 0, 0, 0,
    0, 0, 0, 0, 16, 0, 0, 18, 18, 0, 0, 0, 0, 0, 16, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 19, 19, 16, 0, 19, 19, 0, 17, 16, 16, 17, 0, 0, 0, 0, 16, 19,
    0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 19, 0, 0, 19, 19, 16, 19, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0,
    17, 0, 0, 0, 0, 0, 0, 0, 16, 0, 19, 17, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 0, 0, 0, 16, 17, 19, 0, 0, 0, 0,
    0, 16, 0, 0, 0, 0, 0, 0, 0, 18, 16, 16, 17, 0, 19, 0, 0, 16, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 19, 18, 0, 19, 0, 0,
    0, 16, 0, 16, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 16, 0, 0, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 16, 16, 0, 0, 0, 19, 0, 0,
    0, 19, 0, 0, 16, 16, 0, 0, 0, 16, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 16, 16, 16, 0, 0, 0, 0, 16, 16, 0, 0, 0, 0, 16, 16, 0,
    0, 16, 16, 0, 0, 16, 16, 16, 16, 16, 16, 16, 0, 0, 16, 0, 0, 0, 0, 16, 16, 0, 16, 16, 16, 16, 0, 16, 0, 16, 16, 16, 0,
    0, 16, 0, 0, 0, 0, 0, 0, 16, 0, 19, 0, 0, 0, 0, 0, 16, 16, 16, 16, 0, 0, 16, 16, 19, 0, 0, 16, 16, 0, 0, 0, 0, 0, 0, 0,
    0, 16, 0, 0, 0, 0, 0, 0, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 16,
    0, 0, 0, 0, 0, 0, 0, 19, 0, 19, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0, 0, 0, 19, 19, 0, 19, 0, 0, 19, 19, 0, 0, 16, 19, 17, 19,
    19, 0, 0, 0, 0, 16, 0, 0, 16, 0, 19, 16, 0, 0, 0, 19, 0, 19, 0, 0, 19, 0, 16, 0, 0, 0, 19, 0, 19, 16, 19, 0, 0, 0, 16,
    16, 0, 0, 0, 0, 18, 18, 0, 0, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 19, 0, 0, 0, 0, 16, 0, 0, 0, 0,
    19, 16, 0, 0, 0, 0, 19, 0, 0, 0, 0, 19, 18, 0, 17, 0, 0, 0, 19, 0, 17, 19, 0, 0, 0, 0, 19, 0, 0, 0, 19, 0, 19, 0, 0, 16,
    0, 0, 0, 0, 18, 19, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 18, 0, 0, 19, 0, 0, 0, 0, 0, 19, 0, 0, 0,
    0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 19, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 19, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 16, 0,
    0, 16, 16, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 0, 16, 0, 0, 19, 0, 0, 0, 0, 19, 16, 0, 17, 0,
    16, 0, 18, 19, 0, 0, 16, 18, 0, 0, 16, 19, 19, 16, 0, 0, 0, 0, 17, 18, 19, 18, 0, 0, 16, 19, 0, 0, 0, 19, 19, 0, 0,
    16, 0, 18, 0, 16, 0, 16, 0, 0, 0, 0, 0, 0, 19, 0, 0, 19, 0, 0, 16, 19, 0, 0, 0, 16, 0, 19, 16, 0, 0, 0, 0, 19, 0, 0,
    0, 0, 19, 18, 0, 0, 0, 0, 16, 0, 0, 0, 0, 18, 0, 0, 0, 0,
};

static const char* strBankBinArray[] = {
    "00405512", "交通银行",
    "0049104", "交通银行",
    "0053783", "交通银行",
    "00601428", "交通银行",
    "018572", "农村信用联社",
    "103", "中国农业银行",
    "303", "中国光大银行",
    "356390", "中信银行",
    "356391", "中信银行",
    "356392", "中信银行",
    "356827", "上海银行",
    "356828", "上海银行",
    "356829", "上海银行",
    "356830", "上海银行",
    "356833", "中国银行",
    "356835", "中国银行",
    "356837", "中国光大银行",
    "356838", "中国光大银行",
    "356839", "中国光大银行",
    "356840", "中国光大银行",
    "356850", "上海浦东发展银行",
    "356851", "上海浦东发展银行",
    "356852", "上海浦东发展银行",
    "356856", "中国民生银行",
    "356857", "中国民生银行",
    "356858", "中国民生银行",
    "356859", "中国民生银行",
    "356868", "平安银行",
    "356869", "平安银行",
    "356879", "中国工商银行",
    "356880", "中国工商银行",
    "356881", "中国工商银行",
    "356882", "中国工商银行",
    "356885", "招商银行",
    "356886", "招商银行",
    "356887", "招商银行",
    "356888", "招商银行",
    "356889", "招商银行",
    "356890", "招商银行",
    "356895", "中国建设银行",
    "356896", "中国建设银行",
    "356899", "中国建设银行",
    "360883", "中国工商银行",
    "360884", "中国工商银行",
    "370246", "中国工商银行",
    "370247", "中国工商银行",
    "370248", "中国工商银行",
    "370249", "中国工商银行",
    "370267", "中国工商银行",
    "370285", "招行信用卡支付",
    "370286", "招行信用卡支付",
    "370287", "招行信用卡支付",
    "370289", "招行信用卡支付",
    "374738", "中国工商银行",
    "374739", "中国工商银行",
    "376966", "中信银行",
    "376968", "中信银行",
    "376969", "中信银行",
    "377152", "中国民生银行",
    "377153", "中国民生银行",
    "377155", "中国民生银行",
    "377158", "中国民生银行",
    "377187", "上海浦东发展银行",
    "377677", "中国银行",
    "400360", "中信银行",
    "402658", "招商银行",
    "402673", "上海银行",
    "402674", "上海银行",
    "402791", "中国工商银行",
    "403361", "中国农业银行",
    "403391", "中信银行",
    "403392", "中信银行",
    "403393", "中信银行",
    "404117", "中国农业银行",
    "404118", "中国农业银行",
    "404119", "中国农业银行",
    "404120", "中国农业银行",
    "404121", "中国农业银行",
    "404157", "中信银行",
    "404158", "中信银行",
    "404159", "中信银行",
    "404171", "中信银行",
    "404172", "中信银行",
    "404173", "中信银行",
    "404174", "中信银行",
    "404738", "上海浦东发展银行",
    "404739", "上海浦东发展银行",
    "405512", "交通银行",
    "406252", "中国光大银行",
    "406254", "中国光大银行",
    "406365", "广发银行",
    "406366", "广发银行",
    "407405", "中国民生银行",
    "409665", "中国银行",
    "409666", "中国银行",
    "409667", "中国银行",
    "409668", "中国银行",
    "409669", "中国银行",
    "409670", "中国银行",
    "409671", "中国银行",
    "409672", "中国银行",
    "410062", "招商银行",
    "412962", "平安银行",
    "412963", "平安银行",
    "415599", "中国民生银行",
    "415752", "平安银行",
    "415753", "平安银行",
    "421317", "北京银行",
    "421349", "中国建设银行",
    "421393", "中国民生银行",
    "421865", "中国民生银行",
    "421869", "中国民生银行",
    "421870", "中国民生银行",
    "421871", "中国民生银行",
    "422160", "北京银行",
    "422161", "北京银行",
    "425862", "中国光大银行",
    "427010", "中国工商银行",
    "427018", "中国工商银行",
    "427019", "中国工商银行",
    "427020", "中国工商银行",
    "427028", "中国工商银行",
    "427029", "中国工商银行",
    "427030", "中国工商银行",
    "427038", "中国工商银行",
    "427039", "中国工商银行",
    "427062", "中国工商银行",
    "427064", "中国工商银行",
    "427570", "中国民生银行",
    "427571", "中国民生银行",
    "428911", "广发银行",
    "431502", "华夏银行",
    "431503", "华夏银行",
    "433666", "中信银行",
    "433667", "中信银行",
    "433669", "中信银行",
    "433670", "中信银行",
    "433671", "中信银行",
    "433680", "中信银行",
    "434061", "中国建设银行",
    "434062", "中国建设银行",
    "434910", "交通银行",
    "435744", "平安银行",
    "435745", "平安银行",
    "436718", "中国建设银行",
    "436728", "中国建设银行",
    "436738", "中国建设银行",
    "436742", "中国建设银行",
    "436742193", "中国建设银行",
    "436745", "中国建设银行",
    "436748", "中国建设银行",
    "436768", "广发银行",
    "436769", "广发银行",
    "438088", "中国银行",
    "438125", "中国工商银行",
    "438126", "中国工商银行",
    "438588", "兴业银行",
    "438589", "兴业银行",
    "438600", "上海银行",
    "438617", "中国建设银行",
    "439188", "招商银行",
    "439225", "招行信用卡支付",
    "439226", "招行信用卡支付",
    "439227", "招商银行",
    "442729", "中信银行",
    "442730", "中信银行",
    "451289", "兴业银行",
    "451290", "兴业银行",
    "451804", "中国工商银行",
    "451810", "中国工商银行",
    "451811", "中国工商银行",
    "453242", "中国建设银行",
    "456351", "中国银行",
    "456418", "上海浦东发展银行",
    "45806", "中国工商银行",
    "458071", "中国工商银行",
    "458123", "交通银行",
    "458124", "交通银行",
    "458441", "中国工商银行",
    "461982", "兴业银行",
    "463758", "中国农业银行",
    "464580", "中国民生银行",
    "464581", "中国民生银行",
    "468203", "招商银行",
    "472067", "中国民生银行",
    "472068", "中国民生银行",
    "479228", "招商银行",
    "479229", "招商银行",
    "481699", "中国光大银行",
    "483536", "平安银行",
    "486466", "上海银行",
    "486493", "兴业银行",
    "486494", "兴业银行",
    "486497", "中国光大银行",
    "486861", "兴业银行",
    "487013", "广发银行",
    "489592", "中国建设银行",
    "489734", "中国工商银行",
    "489735", "中国工商银行",
    "489736", "中国工商银行",
    "49102", "中国农业银行",
    "491031", "中国建设银行",
    "491032", "广发银行",
    "491034", "广发银行",
    "491035", "广发银行",
    "491036", "广发银行",
    "491037", "广发银行",
    "491038", "广发银行",
    "49104", "交通银行",
    "498451", "上海浦东发展银行",
    "504923", "江苏银行",
    "510529", "中国工商银行",
    "512315", "中国银行",
    "512316", "中国银行",
    "512411", "中国银行",
    "512412", "中国银行",
    "512425", "招商银行",
    "512431", "宁波银行",
    "512466", "中国民生银行",
    "512732", "中国银行",
    "513685", "中国工商银行",
    "514027", "中国农业银行",
    "514906", "中信银行",
    "514957", "中国银行",
    "514958", "中国银行",
    "515672", "上海浦东发展银行",
    "517636", "中国民生银行",
    "517650", "上海浦东发展银行",
    "518212", "中信银行",
    "518364", "广发银行",
    "518377", "中国银行",
    "518378", "中国银行",
    "518379", "中国银行",
    "518474", "中国银行",
    "518475", "中国银行",
    "518476", "中国银行",
    "518710", "招行信用卡支付",
    "518718", "招行信用卡支付",
    "519412", "中国农业银行",
    "519413", "中国农业银行",
    "519498", "上海银行",
    "519961", "上海银行",
    "520082", "中国农业银行",
    "520083", "中国农业银行",
    "520108", "中信银行",
    "520131", "上海银行",
    "520152", "广发银行",
    "520169", "交通银行",
    "520194", "宁波银行",
    "520382", "广发银行",
    "521302", "招商银行",
    "521899", "交通银行",
    "522001", "北京银行",
    "522964", "交通银行",
    "523036", "兴业银行",
    "523952", "中国民生银行",
    "523959", "华夏银行",
    "524011", "招商银行",
    "524031", "上海银行",
    "524047", "中国工商银行",
    "524070", "兴业银行",
    "524090", "中国光大银行",
    "524091", "中国工商银行",
    "524094", "中国建设银行",
    "524374", "中国工商银行",
    "524864", "中国银行",
    "524865", "中国银行",
    "525498", "中国工商银行",
    "525745", "中国银行",
    "525746", "中国银行",
    "525998", "上海浦东发展银行",
    "526410", "中国建设银行",
    "526836", "中国工商银行",
    "526855", "平安银行",
    "527414", "兴业银行",
    "528020", "平安银行",
    "528057", "兴业银行",
    "528708", "华夏银行",
    "528709", "华夏银行",
    "528856", "中国工商银行",
    "528931", "广发银行",
    "528948", "中国民生银行",
    "530970", "中国工商银行",
    "53098", "中国工商银行",
    "530990", "中国工商银行",
    "531659", "平安银行",
    "531693", "中国建设银行",
    "53242", "中国建设银行",
    "53243", "中国建设银行",
    "532450", "中国建设银行",
    "532458", "中国建设银行",
    "53591", "中国农业银行",
    "53783", "交通银行",
    "539867", "华夏银行",
    "539868", "华夏银行",
    "543098", "中国工商银行",
    "543159", "中国光大银行",
    "543460", "汇丰银行",
    "544033", "中国建设银行",
    "544210", "中国工商银行",
    "544243", "中国农业银行",
    "544887", "中国建设银行",
    "545217", "中国民生银行",
    "5453242", "中国建设银行",
    "545392", "中国民生银行",
    "545393", "中国民生银行",
    "545431", "中国民生银行",
    "545447", "中国民生银行",
    "545619", "招商银行",
    "545620", "招商银行",
    "545621", "招商银行",
    "545623", "招商银行",
    "545947", "招商银行",
    "545948", "招商银行",
    "547766", "中国银行",
    "548259", "中国工商银行",
    "548478", "中国农业银行",
    "548738", "兴业银行",
    "548838", "上海银行",
    "548844", "广发银行",
    "548943", "中国工商银行",
    "5491031", "中国建设银行",
    "549633", "兴业银行",
    "550213", "中国工商银行",
    "552245", "中国建设银行",
    "552288", "中国民生银行",
    "552398", "兴业银行",
    "552534", "招商银行",
    "552587", "招商银行",
    "552599", "中国农业银行",
    "552742", "中国银行",
    "552794", "广发银行",
    "552801", "中国建设银行",
    "552853", "交通银行",
    "553131", "中国银行",
    "553161", "中国民生银行",
    "553242", "中国建设银行",
    "5544033", "中国建设银行",
    "556610", "中国民生银行",
    "556617", "中信银行",
    "557080", "中国建设银行",
    "558360", "中国工商银行",
    "558730", "中国农业银行",
    "558868", "中国银行",
    "558869", "中国银行",
    "558894", "广发银行",
    "558895", "中国建设银行",
    "558916", "中信银行",
    "559051", "中国建设银行",
    "566666", "盛京银行",
    "589856", "渣打银行",
    "589970", "中国建设银行",
    "60110", "DiscoverFinancialServices，I",
    "601100", "DiscoverFinancialServices，I",
    "601101", "DiscoverFinancialServices，I",
    "60112", "DiscoverFinancialServices，I",
    "60112010", "DiscoverFinancialServices，I",
    "60112011", "DiscoverFinancialServices，I",
    "60112012", "DiscoverFinancialServices，I",
    "60112013", "DiscoverFinancialServices，I",
    "60112089", "DiscoverFinancialServices，I",
    "601121", "DiscoverFinancialServices，I",
    "601122", "DiscoverFinancialServices，I",
    "601123", "DiscoverFinancialServices，I",
    "601124", "DiscoverFinancialServices，I",
    "601125", "DiscoverFinancialServices，I",
    "601126", "DiscoverFinancialServices，I",
    "601127", "DiscoverFinancialServices，I",
    "601128", "DiscoverFinancialServices，I",
    "6011290", "DiscoverFinancialServices，I",
    "6011291", "DiscoverFinancialServices，I",
    "6011292", "DiscoverFinancialServices，I",
    "6011293", "DiscoverFinancialServices，I",
    "6011294", "DiscoverFinancialServices，I",
    "6011295", "DiscoverFinancialServices，I",
    "6011296", "DiscoverFinancialServices，I",
    "6011297", "DiscoverFinancialServices，I",
    "60112980", "DiscoverFinancialServices，I",
    "60112981", "DiscoverFinancialServices，I",
    "60112986", "DiscoverFinancialServices，I",
    "60112987", "DiscoverFinancialServices，I",
    "60112988", "DiscoverFinancialServices，I",
    "60112989", "DiscoverFinancialServices，I",
    "60112990", "DiscoverFinancialServices，I",
    "60112991", "DiscoverFinancialServices，I",
    "60112992", "DiscoverFinancialServices，I",
    "60112993", "DiscoverFinancialServices，I",
    "60112994", "DiscoverFinancialServices，I",
    "60112995", "DiscoverFinancialServices，I",
    "60112996", "DiscoverFinancialServices，I",
    "60112997", "DiscoverFinancialServices，I",
    "60113", "DiscoverFinancialServices，I",
    "6011300", "DiscoverFinancialServices，I",
    "60113080", "DiscoverFinancialServices，I",
    "60113081", "DiscoverFinancialServices，I",
    "60113089", "DiscoverFinancialServices，I",
    "601131", "DiscoverFinancialServices，I",
    "601136", "DiscoverFinancialServices，I",
    "601137", "DiscoverFinancialServices，I",
    "601138", "DiscoverFinancialServices，I",
    "6011390", "DiscoverFinancialServices，I",
    "6011391", "DiscoverFinancialServices，I",
    "6011392", "DiscoverFinancialServices，I",
    "6011393", "DiscoverFinancialServices，I",
    "60113940", "DiscoverFinancialServices，I",
    "60113941", "DiscoverFinancialServices，I",
    "60113943", "DiscoverFinancialServices，I",
    "60113944", "DiscoverFinancialServices，I",
    "60113945", "DiscoverFinancialServices，I",
    "60113946", "DiscoverFinancialServices，I",
    "60113984", "DiscoverFinancialServices，I",
    "60113985", "DiscoverFinancialServices，I",
    "60113986", "DiscoverFinancialServices，I",
    "60113988", "DiscoverFinancialServices，I",
    "60113989", "DiscoverFinancialServices，I",
    "6011399", "DiscoverFinancialServices，I",
    "60114", "DiscoverFinancialServices，I",
    "601140", "DiscoverFinancialServices，I",
    "601142", "DiscoverFinancialServices，I",
    "601143", "DiscoverFinancialServices，I",
    "601144", "DiscoverFinancialServices，I",
    "601145", "DiscoverFinancialServices，I",
    "601146", "DiscoverFinancialServices，I",
    "601147", "DiscoverFinancialServices，I",
    "601148", "DiscoverFinancialServices，I",
    "601149", "DiscoverFinancialServices，I",
    "601174", "DiscoverFinancialServices，I",
    "601177", "DiscoverFinancialServices，I",
    "601178", "DiscoverFinancialServices，I",
    "601179", "DiscoverFinancialServices，I",
    "601186", "DiscoverFinancialServices，I",
    "601187", "DiscoverFinancialServices，I",
    "601188", "DiscoverFinancialServices，I",
    "601189", "DiscoverFinancialServices，I",
    "60119", "DiscoverFinancialServices，I",
    "601210", "邮储银行",
    "601382", "中国银行",
    "601428", "交通银行",
    "602907", "平安银行",
    "602969", "北京银行",
    "602970", "邮储银行",
    "60326500", "无锡市商业银行",
    "60326513", "无锡市商业银行",
    "603367", "杭州银行",
    "603367", "杭州银行",
    "603445", "广州银行",
    "603506", "苏州银行",
    "603601", "徽商银行",
    "603602", "绍兴银行",
    "603610", "邮储银行",
    "603694", "农村商业银行",
    "603708", "大连银行",
    "606672", "邮储银行",
    "6091201", "天津银行",
    "620009", "越南西贡商业银行",
    "620010", "平安银行",
    "620011", "BC卡公司",
    "620013", "交通银行",
    "620015", "新加坡星网电子付款私人有限公司",
    "620019", "中国银行",
    "620021", "交通银行",
    "620024", "RoyalBankOpenStockCompany",
    "620025", "中国银行",
    "620026", "中国银行",
    "620027", "BC卡公司",
    "620030", "中国工商银行",
    "620031", "BC卡公司",
    "620035", "中国银行",
    "620037", "广发银行",
    "620038", "中国银行",
    "620039", "BC卡公司",
    "620040", "中国银行",
    "620043", "海峡银行",
    "620046", "中国工商银行",
    "620048", "中国银行",
    "620050", "中国工商银行",
    "620054", "中国工商银行",
    "620056", "CreditSaison",
    "620058", "中国工商银行",
    "620059", "中国农业银行",
    "620060", "中国建设银行",
    "620061", "中国银行",
    "620062", "邮政储蓄",
    "620068", "中国银盛",
    "620070", "中国银盛",
    "620072", "大丰银行有限公司",
    "620079", "CommercialBankofDubai",
    "620082", "中信银行",
    "620085", "中国光大银行",
    "620086", "中国工商银行",
    "620088", "农村商业银行",
    "620091", "CommercialBankofDubai",
    "620094", "中国工商银行",
    "620101", "中国工商银行",
    "620103", "BC卡公司",
    "620105", "TheBancorpBank",
    "620106", "BC卡公司",
    "620107", "中国建设银行",
    "620108", "RussianStandardBank",
    "6201086", "RussianStandardBank",
    "6201088", "RussianStandardBank",
    "620114", "中国工商银行",
    "620118", "柳州银行",
    "620120", "BC卡公司",
    "620123", "BC卡公司",
    "620124", "中国工商银行",
    "620125", "BC卡公司",
    "620126", "澳门通股份有限公司",
    "620129", "TheMauritiusCommercialBank",
    "620132", "BC卡公司",
    "620142", "中国工商银行",
    "620143", "中国工商银行",
    "620146", "中国工商银行",
    "620148", "中国工商银行",
    "620149", "中国工商银行",
    "620152", "Travelex",
    "620153", "Travelex",
    "620183", "中国工商银行",
    "620184", "中国工商银行",
    "620185", "中国工商银行",
    "620186", "中国工商银行",
    "620187", "中国工商银行",
    "620200", "中国工商银行",
    "620202", "中国银行",
    "620203", "中国银行",
    "620204", "大丰银行有限公司",
    "620205", "大丰银行有限公司",
    "620206", "集友银行",
    "620207", "集友银行",
    "620208", "南洋商业银行",
    "620209", "南洋商业银行",
    "620210", "中国银行",
    "620211", "中国银行",
    "620220", "BC卡公司",
    "620278", "BC卡公司",
    "620302", "中国工商银行",
    "620402", "中国工商银行",
    "620403", "中国工商银行",
    "620404", "中国工商银行",
    "620405", "中国工商银行",
    "620406", "中国工商银行",
    "620407", "中国工商银行",
    "620408", "中国工商银行",
    "620409", "中国工商银行",
    "620410", "中国工商银行",
    "620411", "中国工商银行",
    "620412", "中国工商银行",
    "620500", "农村信用联社",
    "620501", "中国农业银行",
    "620502", "中国工商银行",
    "620503", "中国工商银行",
    "620512", "中国工商银行",
    "620513", "中国银行",
    "620514", "中国银行",
    "620515", "中国银行",
    "620516", "中国工商银行",
    "620517", "浙江民泰商业银行",
    "620518", "中国光大银行",
    "620519", "长沙银行",
    "620520", "招商银行",
    "620521", "交通银行",
    "620522", "上海银行",
    "620527", "中信银行",
    "620528", "邢台银行",
    "620529", "邮政储蓄",
    "620530", "上海浦东发展银行",
    "620531", "中国银行",
    "620532", "澳门通股份有限公司",
    "620533", "宁波银行",
    "620535", "中国光大银行",
    "620537", "澳门通股份有限公司",
    "620550", "中国银行",
    "620551", "青岛银行",
    "620552", "华夏银行",
    "620561", "中国工商银行",
    "620602", "中国工商银行",
    "620604", "中国工商银行",
    "620607", "中国工商银行",
    "620609", "中国工商银行",
    "620611", "中国工商银行",
    "620612", "中国工商银行",
    "620704", "中国工商银行",
    "620706", "中国工商银行",
    "620707", "中国工商银行",
    "620708", "中国工商银行",
    "620709", "中国工商银行",
    "620710", "中国工商银行",
    "620711", "中国工商银行",
    "620712", "中国工商银行",
    "620713", "中国工商银行",
    "620714", "中国工商银行",
    "620802", "中国工商银行",
    "620812", "BC卡公司",
    "620902", "中国工商银行",
    "620904", "中国工商银行",
    "620905", "中国工商银行",
    "621001", "中国工商银行",
    "621002", "交通银行",
    "621003", "BC卡公司",
    "621004", "东营银行",
    "621005", "上海银行",
    "621006", "BC卡公司",
    "621008", "农村信用联社",
    "621010", "平凉市商业银行",
    "621011", "BC卡公司",
    "621012", "BC卡公司",
    "621013", "农村信用联社",
    "621014", "上饶银行",
    "621015", "新加坡星展银行",
    "621016", "新加坡星展银行",
    "621017", "农村信用联社",
    "621018", "农村信用联社",
    "621019", "浙商银行",
    "621020", "BC卡公司",
    "621021", "农村信用联社",
    "621023", "BC卡公司",
    "621024", "农村信用联社",
    "621025", "BC卡公司",
    "621026", "农村信用联社",
    "621027", "BC卡公司",
    "621028", "浙江稠州商业银行",
    "621029", "昆仑银行",
    "621030", "北京银行",
    "621031", "BC卡公司",
    "621032", "BC卡公司",
    "621033", "农村信用联社",
    "621034", "上海银行",
    "621035", "许昌银行",
    "621036", "农村信用联社",
    "621037", "龙江银行",
    "621038", "铁岭银行",
    "621039", "BC卡公司",
    "621040", "莫斯科人民储蓄银行",
    "621041", "中国银行",
    "621042", "南洋商业银行",
    "621043", "集友银行",
    "621044", "城市商业银行(宝鸡市)",
    "621045", "丝绸之路银行",
    "621049", "蒙古郭勒姆特银行",
    "621050", "上海银行",
    "621053", "村镇银行",
    "621055", "越南西贡商业银行",
    "621056801", "村镇银行",
    "621056802", "村镇银行",
    "621056803", "村镇银行",
    "621057", "城市商业银行(凉山州)",
    "621058", "农村信用联社",
    "62105900", "村镇银行",
    "62105901", "村镇银行",
    "62105905", "村镇银行",
    "62105913", "村镇银行",
    "62105915", "村镇银行",
    "62105916", "村镇银行",
    "621060", "友利银行",
    "621061", "农村信用联社",
    "621062", "花旗银行",
    "621063", "花旗银行",
    "621064", "AEON信贷财务亚洲有限公司",
    "621065", "农村信用联社",
    "621066", "农村商业银行",
    "621067", "农村商业银行",
    "621068", "农村商业银行",
    "621069", "交通银行",
    "621070", "城市商业银行(自贡市)",
    "621071", "城市商业银行(平顶山市)",
    "621072", "新韩银行",
    "621073", "天津滨海农村商业银行股份有限公司",
    "621074", "朝阳市商业银行",
    "621075", "漯河银行",
    "621076", "江苏银行",
    "621077", "华侨银行",
    "621078", "BC卡公司",
    "621080", "中国建设银行",
    "621081", "中国建设银行",
    "621082", "中国建设银行",
    "621083", "中国建设银行",
    "621084", "中国建设银行",
    "621086", "城市商业银行(乐山市)",
    "621087", "创兴银行有限公司",
    "621088", "浙江民泰商业银行",
    "621089", "城市商业银行(盘锦市)",
    "621090", "城市商业银行(遂宁市)",
    "621091", "保定银行",
    "621092001", "村镇银行",
    "621092002", "村镇银行",
    "621092003", "村镇银行",
    "621092004", "村镇银行",
    "621092005", "村镇银行",
    "621092006", "村镇银行",
    "621092007", "村镇银行",
    "621092008", "农村信用联社",
    "62109207", "村镇银行",
    "621095", "邮政储蓄",
    "621096", "邮政储蓄",
    "621097", "龙江银行",
    "621098", "邮政储蓄",
    "621099", "农村信用联社",
    "621102", "中国工商银行",
    "621103", "中国工商银行",
    "621105", "中国工商银行",
    "621106", "中国工商银行",
    "621107", "中国工商银行",
    "621200", "济宁银行",
    "621201", "韩亚银行",
    "621202", "中国工商银行",
    "621203", "中国工商银行",
    "621204", "中国工商银行",
    "621205", "中国工商银行",
    "621206", "中国工商银行",
    "621207", "中国工商银行",
    "621208", "中国工商银行",
    "621209", "中国工商银行",
    "621210", "中国工商银行",
    "621211", "中国工商银行",
    "621212", "中国银行",
    "621213", "南洋商业银行",
    "621215", "中国银行",
    "621216", "晋商银行",
    "621217", "湖北银行",
    "621218", "中国工商银行",
    "621219", "村镇银行",
    "621220", "BC卡公司",
    "621221", "城市商业银行(驻马店市)",
    "621222", "华夏银行",
    "621223", "城市商业银行(晋中市)",
    "621224", "可汗银行",
    "621225", "中国工商银行",
    "621226", "中国工商银行",
    "621227", "中国工商银行",
    "621228", "农村信用联社",
    "621229", "村镇银行",
    "621230", "村镇银行",
    "621231", "中国银行",
    "621232", "大西洋银行股份有限公司",
    "621233", "达州市商业银行",
    "621234", "CSC",
    "621235", "城市商业银行(新乡市)",
    "621237", "秦皇岛银行",
    "621238", "邢台银行",
    "621239", "城市商业银行(衡水市)",
    "621240", "中国工商银行",
    "621241001", "村镇银行",
    "621242", "兰州银行",
    "621244", "盛京银行",
    "621245", "法国兴业银行",
    "621247", "大西洋银行股份有限公司",
    "621248", "中国银行",
    "621249", "中国银行",
    "621250001", "村镇银行",
    "621250002", "村镇银行",
    "621250003", "村镇银行",
    "621250004", "村镇银行",
    "621250005", "村镇银行",
    "621250006", "村镇银行",
    "621250007", "村镇银行",
    "621250008", "村镇银行",
    "621250009", "村镇银行",
    "621250010", "村镇银行",
    "621250011", "村镇银行",
    "621250012", "村镇银行",
    "621251", "农村信用联社",
    "621252", "青岛银行",
    "621253", "澳门商业银行",
    "621254", "澳门商业银行",
    "621255", "澳门商业银行",
    "621256", "中国银行",
    "621257", "BaiduriBankBerhad",
    "621258", "农村商业银行",
    "621259", "南京银行",
    "621260001", "村镇银行",
    "621260002", "村镇银行",
    "621263", "库尔勒市商业银行",
    "621264", "俄罗斯远东商业银行",
    "621265001", "村镇银行",
    "621266", "沧州银行",
    "621267", "海峡银行",
    "621268", "渤海银行",
    "621269", "南昌银行",
    "621270", "湖北银行",
    "621271", "周口银行",
    "621272", "阳泉市商业银行",
    "621273", "城市商业银行(宜宾市)",
    "621274", "澳门BDA",
    "621275111", "村镇银行",
    "621275121", "村镇银行",
    "621275131", "村镇银行",
    "621275141", "村镇银行",
    "621275151", "村镇银行",
    "621275161", "村镇银行",
    "621275171", "村镇银行",
    "621275181", "村镇银行",
    "621275191", "村镇银行",
    "621275211", "村镇银行",
    "621275231", "村镇银行",
    "621275241", "村镇银行",
    "621275261", "村镇银行",
    "621275271", "村镇银行",
    "621275281", "村镇银行",
    "621275301", "村镇银行",
    "621277", "大新银行",
    "621278293", "村镇银行",
    "621278333", "村镇银行",
    "621278503", "村镇银行",
    "621279", "宁波银行",
    "621280", "农村信用联社",
    "621281", "中国工商银行",
    "621282", "中国农业银行",
    "621283", "中国银行",
    "621284", "中国建设银行",
    "621285", "邮政储蓄",
    "621286", "招商银行",
    "621287", "农村信用联社",
    "621288", "中国工商银行",
    "621289", "南洋商业银行",
    "621290", "南洋商业银行",
    "621291", "南洋商业银行",
    "621292", "南洋商业银行",
    "621293", "中国银行",
    "621294", "中国银行",
    "621295", "越南Vietcombank",
    "621296", "长安银行",
    "621297", "中国银行",
    "621298", "永亨银行",
    "621299", "招商银行",
    "621300", "中国工商银行",
    "621301", "格鲁吉亚InvestBank",
    "621302", "中国工商银行",
    "621303", "中国工商银行",
    "621304", "中国工商银行",
    "621305", "中国工商银行",
    "621306", "中国工商银行",
    "621307", "中国工商银行",
    "621308", "村镇银行",
    "621309", "中国工商银行",
    "621310", "村镇银行",
    "621311", "中国工商银行",
    "621313", "中国工商银行",
    "621315", "中国工商银行",
    "621316001", "村镇银行",
    "621317", "中国工商银行",
    "621324", "澳门BDA",
    "621325", "城市商业银行(雅安地区)",
    "621326763", "村镇银行",
    "621326919", "村镇银行",
    "621326939", "村镇银行",
    "621326949", "村镇银行",
    "621326969", "村镇银行",
    "621327", "城市商业银行(安阳市)",
    "621328", "大华银行",
    "621330", "中国银行",
    "621331", "中国银行",
    "621332", "中国银行",
    "621333", "中国银行",
    "621334", "中国银行",
    "621335", "交通银行",
    "621336", "中国农业银行",
    "621337", "商丘银行",
    "621338001", "村镇银行",
    "621338002", "村镇银行",
    "621338005", "村镇银行",
    "621338006", "村镇银行",
    "621338008", "村镇银行",
    "621338009", "村镇银行",
    "621338010", "村镇银行",
    "621339", "新疆汇和银行",
    "621340", "廊坊银行",
    "621341", "廊坊银行",
    "621342", "中国银行",
    "621343", "中国银行",
    "621344", "RoyalBankOpenStockCompany",
    "621345", "宁波东海银行",
    "621346001", "村镇银行",
    "621346002", "村镇银行",
    "621346003", "村镇银行",
    "621347001", "村镇银行",
    "621347002", "村镇银行",
    "621347003", "村镇银行",
    "621347005", "村镇银行",
    "621347006", "村镇银行",
    "621347007", "村镇银行",
    "621347008", "村镇银行",
    "621348", "营口沿海银行",
    "621349", "乌兹别克斯坦INFINBANK",
    "621350001", "村镇银行",
    "621350002", "村镇银行",
    "621350003", "村镇银行",
    "621350004", "村镇银行",
    "621350005", "村镇银行",
    "621350006", "村镇银行",
    "621350007", "村镇银行",
    "621350008", "村镇银行",
    "621350009", "村镇银行",
    "621350010", "村镇银行",
    "621350011", "村镇银行",
    "621350012", "村镇银行",
    "621350013", "村镇银行",
    "621350014", "村镇银行",
    "621350015", "村镇银行",
    "621350016", "村镇银行",
    "621350017", "村镇银行",
    "621350018", "村镇银行",
    "621350019", "村镇银行",
    "621350020", "村镇银行",
    "621350431", "村镇银行",
    "621350451", "村镇银行",
    "621350755", "村镇银行",
    "621350943", "村镇银行",
    "621351", "上海浦东发展银行",
    "621352", "上海浦东发展银行",
    "621353001", "新华村镇银行",
    "621353002", "新华村镇银行",
    "621353003", "新华村镇银行",
    "621353005", "新华村镇银行",
    "621353006", "新华村镇银行",
    "621353007", "新华村镇银行",
    "621353008", "新华村镇银行",
    "621353101", "新华村镇银行",
    "621353102", "新华村镇银行",
    "621353103", "新华村镇银行",
    "621353105", "新华村镇银行",
    "621353107", "新华村镇银行",
    "621353108", "新华村镇银行",
    "621354", "BCEL",
    "621355001", "村镇银行",
    "621355002", "村镇银行",
    "621356001", "村镇银行",
    "621356002", "村镇银行",
    "621356003", "村镇银行",
    "621356004", "村镇银行",
    "621356005", "村镇银行",
    "621356006", "村镇银行",
    "621356007", "村镇银行",
    "621356008", "村镇银行",
    "621356009", "村镇银行",
    "621356010", "村镇银行",
    "621356011", "村镇银行",
    "621356012", "村镇银行",
    "621356013", "村镇银行",
    "621356014", "村镇银行",
    "621356015", "村镇银行",
    "621356016", "村镇银行",
    "621356017", "村镇银行",
    "621356018", "村镇银行",
    "621356021", "村镇银行",
    "621356022", "村镇银行",
    "621356023", "村镇银行",
    "621356024", "村镇银行",
    "621356025", "村镇银行",
    "621356026", "村镇银行",
    "621356028", "村镇银行",
    "621356029", "村镇银行",
    "621356030", "村镇银行",
    "621356031", "村镇银行",
    "621356032", "村镇银行",
    "621356034", "村镇银行",
    "621356036", "村镇银行",
    "621356037", "村镇银行",
    "621356039", "村镇银行",
    "621356040", "村镇银行",
    "621356041", "村镇银行",
    "621356044", "村镇银行",
    "621356046", "村镇银行",
    "621356049", "村镇银行",
    "621359", "城市商业银行(景德镇市)",
    "621360", "城市商业银行(哈密地区)",
    "621361", "农村商业银行",
    "621362", "农村信用联社",
    "621363", "农村商业银行",
    "621364", "中国银行",
    "621365001", "村镇银行",
    "621365002", "村镇银行",
    "621365003", "村镇银行",
    "621365004", "村镇银行",
    "621365005", "村镇银行",
    "621365006", "村镇银行",
    "621365007", "村镇银行",
    "621365008", "村镇银行",
    "621366", "华融湘江银行",
    "621367", "中国工商银行",
    "621368001", "村镇银行",
    "621369", "中国工商银行",
    "621370", "中国工商银行",
    "621371", "中国工商银行",
    "621372", "中国工商银行",
    "62137310", "中国工商银行",
    "62137320", "中国工商银行",
    "621374", "中国工商银行",
    "621375", "中国工商银行",
    "621376", "中国工商银行",
    "621377", "中国工商银行",
    "621378", "中国工商银行",
    "621379", "中国工商银行",
    "621382001", "村镇银行",
    "621382002", "村镇银行",
    "621382003", "村镇银行",
    "621382004", "村镇银行",
    "621382005", "村镇银行",
    "621382006", "村镇银行",
    "621382007", "村镇银行",
    "621382008", "村镇银行",
    "621382009", "村镇银行",
    "621382010", "村镇银行",
    "621382011", "村镇银行",
    "621382012", "村镇银行",
    "621382013", "村镇银行",
    "621382014", "村镇银行",
    "621382015", "村镇银行",
    "621382016", "村镇银行",
    "621382017", "村镇银行",
    "621382018", "村镇银行",
    "621382019", "村镇银行",
    "621382020", "村镇银行",
    "621382021", "村镇银行",
    "621382022", "村镇银行",
    "621382023", "村镇银行",
    "621382024", "村镇银行",
    "621382025", "村镇银行",
    "621382026", "村镇银行",
    "621382027", "村镇银行",
    "621383001", "村镇银行",
    "621383002", "村镇银行",
    "621385663", "村镇银行",
    "621386001", "村镇银行",
    "621386002", "村镇银行",
    "621386003", "村镇银行",
    "621386004", "村镇银行",
    "621387973", "村镇银行",
    "621388", "华融湘江银行",
    "621390", "上海浦东发展银行",
    "621391", "西藏银行",
    "621392", "村镇银行",
    "621393001", "村镇银行",
    "621394", "中国银行",
    "621395", "中国银行",
    "621396", "村镇银行",
    "621397001", "村镇银行",
    "621398001", "村镇银行",
    "621399001", "村镇银行",
    "621399002", "村镇银行",
    "621399003", "村镇银行",
    "621399005", "村镇银行",
    "621399006", "村镇银行",
    "621399007", "村镇银行",
    "621399008", "村镇银行",
    "621399009", "村镇银行",
    "621399010", "村镇银行",
    "621399011", "村镇银行",
    "621399011", "村镇银行",
    "621399012", "村镇银行",
    "621399013", "村镇银行",
    "621399014", "村镇银行",
    "621399015", "村镇银行",
    "621399016", "村镇银行",
    "621399017", "村镇银行",
    "621399018", "村镇银行",
    "621399019", "村镇银行",
    "621399020", "村镇银行",
    "621399021", "村镇银行",
    "621399022", "村镇银行",
    "621399023", "村镇银行",
    "621399024", "村镇银行",
    "621399025", "村镇银行",
    "621399026", "村镇银行",
    "621399027", "村镇银行",
    "621399028", "村镇银行",
    "621401001", "村镇银行",
    "621402", "中国工商银行",
    "621403", "莱商银行",
    "621404", "中国工商银行",
    "621405", "中国工商银行",
    "621406", "中国工商银行",
    "621407", "中国工商银行",
    "621408", "中国工商银行",
    "621409", "中国工商银行",
    "621410", "中国工商银行",
    "621411", "东亚银行",
    "621412", "柳州银行",
    "621413", "张家口市商业银行",
    "621414", "中国工商银行",
    "621415", "昆明商业银行",
    "621416", "上饶银行",
    "621417", "宁夏银行",
    "621418", "宁波银行",
    "621419", "青岛银行",
    "621420", "北京银行",
    "621422", "沧州银行",
    "621423", "中国工商银行",
    "621428", "中国工商银行",
    "621433", "中国工商银行",
    "621434", "中国工商银行",
    "621436", "交通银行",
    "621437", "城市商业银行(泉州市)",
    "621439", "东莞银行",
    "621440", "恒生银行",
    "621441", "恒生银行",
    "621442", "汇丰银行",
    "621443", "汇丰银行",
    "6214455", "PTBankSinarmas",
    "6214458", "PTBankSinarmas",
    "621446", "长沙银行",
    "621448", "长安银行",
    "621449", "农村信用联社",
    "621452", "天津银行",
    "621453", "渤海银行",
    "621455", "珠海华润银行",
    "621456", "桂林银行",
    "621457", "农村信用联社",
    "621458", "农村信用联社",
    "621459", "农村信用联社",
    "621460", "贵州银行",
    "621461", "苏州银行",
    "621462", "广发银行",
    "621463", "广州银行",
    "621464", "中国工商银行",
    "621465", "农村商业银行",
    "621466", "中国建设银行",
    "621467", "中国建设银行",
    "621468", "北京银行",
    "621469", "华兴银行",
    "621475", "中国工商银行",
    "621476", "中国工商银行",
    "621480", "城市信用联社",
    "621481", "村镇银行",
    "621482", "成都银行",
    "621483", "招商银行",
    "621484", "BC卡公司",
    "621485", "招商银行",
    "621486", "招商银行",
    "621487", "中国建设银行",
    "621488", "中国建设银行",
    "621489", "中国光大银行",
    "621490", "中国光大银行",
    "621491", "中国光大银行",
    "621492", "中国光大银行",
    "621495", "农村商业银行",
    "621496", "兰州银行",
    "621497", "曲靖市商业银行",
    "621498", "城市商业银行(乐山市)",
    "621499", "中国建设银行",
    "621502", "中国工商银行",
    "621511", "中国工商银行",
    "621515", "朝阳市商业银行",
    "621516", "农村商业银行",
    "621517", "农村信用联社",
    "621518", "农村信用联社",
    "621519", "农村信用联社",
    "621520", "农村信用联社",
    "621521", "农村信用联社",
    "621522", "农村商业银行",
    "621523", "农村信用联社",
    "621525", "农村信用联社",
    "621526", "农村信用联社",
    "621527", "农村信用联社",
    "621528", "农村商业银行",
    "621529", "宁夏银行",
    "621530", "农村信用联社",
    "621531", "农村信用联社",
    "621532", "成都银行",
    "621533", "农村信用联社",
    "621536", "农村信用联社",
    "621538", "兰州银行",
    "621539", "农村信用联社",
    "621557", "农村信用联社",
    "621558", "中国工商银行",
    "621559", "中国工商银行",
    "621560", "农村商业银行",
    "621561", "农村商业银行",
    "621562", "桂林银行",
    "621563", "中国银行",
    "621566", "农村信用联社",
    "621568", "中国银行",
    "621569", "中国银行",
    "621577", "哈尔滨银行",
    "621578", "农村信用联社",
    "621579", "江苏银行",
    "621580", "农村信用联社",
    "621585", "农村信用联社",
    "621588", "龙江银行",
    "621589", "农村信用联社",
    "621590", "农村信用联社",
    "621591", "贵州银行",
    "621592", "农村信用联社",
    "621598", "中国建设银行",
    "621599", "邮政储蓄",
    "621600", "厦门银行",
    "621601", "城市商业银行(濮阳市)",
    "621602", "中国工商银行",
    "621603", "中国工商银行",
    "621604", "中国工商银行",
    "621605", "中国工商银行",
    "621606", "中国工商银行",
    "621607", "中国工商银行",
    "621608", "中国工商银行",
    "621609", "中国工商银行",
    "621610", "中国工商银行",
    "621611", "中国工商银行",
    "621612", "中国工商银行",
    "621613", "中国工商银行",
    "621614", "中国工商银行",
    "621615", "中国工商银行",
    "621616", "中国工商银行",
    "621617", "中国工商银行",
    "621618", "中国工商银行",
    "621619", "中国农业银行",
    "621620", "中国银行",
    "621621", "中国建设银行",
    "621622", "邮政储蓄",
    "621623001", "村镇银行",
    "621624", "OJSCBASIAALLIANCEBANK",
    "621625", "华兴银行",
    "621626", "平安银行",
    "621627001", "村镇银行",
    "621627003", "村镇银行",
    "621627005", "村镇银行",
    "621627006", "村镇银行",
    "621627007", "村镇银行",
    "621627008", "村镇银行",
    "621627009", "村镇银行",
    "621627010", "村镇银行",
    "621628660", "村镇银行",
    "621628661", "村镇银行",
    "621628662", "村镇银行",
    "621630001", "村镇银行",
    "621630002", "村镇银行",
    "62163101", "村镇银行",
    "62163102", "村镇银行",
    "62163103", "村镇银行",
    "62163104", "村镇银行",
    "62163107", "村镇银行",
    "62163108", "村镇银行",
    "62163109", "村镇银行",
    "62163110", "村镇银行",
    "62163111", "村镇银行",
    "62163112", "村镇银行",
    "62163113", "村镇银行",
    "62163114", "村镇银行",
    "62163115", "村镇银行",
    "62163116", "村镇银行",
    "62163117", "村镇银行",
    "62163118", "村镇银行",
    "62163119", "村镇银行",
    "62163120", "村镇银行",
    "62163121", "村镇银行",
    "621633", "内蒙古银行",
    "621635003", "村镇银行",
    "621635004", "村镇银行",
    "621635005", "村镇银行",
    "621635007", "村镇银行",
    "621635010", "村镇银行",
    "621635013", "村镇银行",
    "621635101", "村镇银行",
    "621635102", "村镇银行",
    "621635103", "村镇银行",
    "621635104", "村镇银行",
    "621635105", "村镇银行",
    "621635106", "村镇银行",
    "621635108", "村镇银行",
    "621635109", "村镇银行",
    "621635110", "村镇银行",
    "621635111", "村镇银行",
    "621635112", "村镇银行",
    "621635113", "村镇银行",
    "621635114", "村镇银行",
    "621635115", "村镇银行",
    "621635118", "村镇银行",
    "621636", "甘肃银行",
    "621637001", "村镇银行",
    "621637002", "村镇银行",
    "621637003", "村镇银行",
    "621637004", "村镇银行",
    "621637005", "村镇银行",
    "621637006", "村镇银行",
    "621637007", "村镇银行",
    "621637008", "村镇银行",
    "621637009", "村镇银行",
    "621638", "中国银行",
    "621640", "BC卡公司",
    "621641", "BC卡公司",
    "621642", "MongoliaTradeDevelop.Bank",
    "621645", "巴基斯坦FAYSALBANK",
    "621647", "俄罗斯ORIENTEXPRESSBANK",
    "621648", "中国银行",
    "621649", "CJSCFononbank",
    "621650001", "村镇银行",
    "621650002", "村镇银行",
    "621651", "企业银行（中国）",
    "621653001", "村镇银行",
    "621653002", "村镇银行",
    "621653003", "村镇银行",
    "621653004", "村镇银行",
    "621653005", "村镇银行",
    "621653006", "村镇银行",
    "621653007", "村镇银行",
    "621654", "KrungThajBankPublicCo.Ltd",
    "621655", "宁波通商银行",
    "621656001", "村镇银行",
    "621656002", "村镇银行",
    "62165666", "村镇银行",
    "621657", "巴基斯坦HabibBank",
    "621659001", "村镇银行",
    "621659002", "村镇银行",
    "621659006", "村镇银行",
    "621660", "中国银行",
    "621661", "中国银行",
    "621662", "中国银行",
    "621663", "中国银行",
    "621665", "中国银行",
    "621666", "中国银行",
    "621667", "中国银行",
    "621668", "中国银行",
    "621669", "中国银行",
    "621670", "中国工商银行",
    "621671", "中国农业银行",
    "621672", "中国银行",
    "621673", "中国建设银行",
    "621674", "邮政储蓄",
    "621675001", "村镇银行",
    "621676001", "村镇银行",
    "621676002", "村镇银行",
    "621676003", "村镇银行",
    "621678001", "村镇银行",
    "621678101", "村镇银行",
    "621678201", "村镇银行",
    "621678202", "村镇银行",
    "621678208", "村镇银行",
    "621678212", "村镇银行",
    "621680002", "村镇银行",
    "621680003", "村镇银行",
    "621680004", "村镇银行",
    "621680005", "村镇银行",
    "621680006", "村镇银行",
    "621680007", "村镇银行",
    "621680008", "村镇银行",
    "621680009", "村镇银行",
    "621680010", "村镇银行",
    "621680011", "村镇银行",
    "621681001", "村镇银行",
    "621681002", "村镇银行",
    "621681003", "村镇银行",
    "621682002", "村镇银行",
    "621682003", "村镇银行",
    "621682101", "村镇银行",
    "621682102", "村镇银行",
    "621682103", "村镇银行",
    "621682105", "村镇银行",
    "621682106", "村镇银行",
    "621682107", "村镇银行",
    "621682108", "村镇银行",
    "621682109", "村镇银行",
    "621682110", "村镇银行",
    "621682111", "村镇银行",
    "621682201", "村镇银行",
    "621682202", "村镇银行",
    "621682203", "村镇银行",
    "621682205", "村镇银行",
    "621682206", "村镇银行",
    "621682207", "村镇银行",
    "621682208", "村镇银行",
    "621682209", "村镇银行",
    "621682210", "村镇银行",
    "621682211", "村镇银行",
    "621682212", "村镇银行",
    "621682213", "村镇银行",
    "621682301", "村镇银行",
    "621682302", "村镇银行",
    "621682303", "村镇银行",
    "621682305", "村镇银行",
    "621682306", "村镇银行",
    "621682307", "村镇银行",
    "621682308", "村镇银行",
    "621682309", "村镇银行",
    "621682310", "村镇银行",
    "621682311", "村镇银行",
    "62168301", "村镇银行",
    "62168302", "村镇银行",
    "62168303", "村镇银行",
    "62168304", "村镇银行",
    "62168305", "村镇银行",
    "62168308", "村镇银行",
    "6216846", "RussianStandardBank",
    "6216848", "RussianStandardBank",
    "621687001", "村镇银行",
    "621687913", "村镇银行",
    "621688", "农村商业银行",
    "621689001", "村镇银行",
    "621689002", "村镇银行",
    "621689003", "村镇银行",
    "621689004", "村镇银行",
    "621689005", "村镇银行",
    "621689006", "村镇银行",
    "621689007", "村镇银行",
    "621690", "农村信用联社",
    "621691", "中国民生银行",
    "621694", "CapitalBankofMongolia",
    "62169501", "村镇银行",
    "62169502", "村镇银行",
    "62169503", "村镇银行",
    "621696", "城市商业银行(本溪市)",
    "621697793", "村镇银行",
    "621697813", "村镇银行",
    "621697873", "村镇银行",
    "621699001", "村镇银行",
    "621699002", "村镇银行",
    "621699002", "村镇银行",
    "621699003", "村镇银行",
    "621700", "中国建设银行",
    "621701", "农村信用联社",
    "621719", "中国工商银行",
    "621719", "中国工商银行",
    "621720", "中国工商银行",
    "621721", "中国工商银行",
    "621722", "中国工商银行",
    "621723", "中国工商银行",
    "621724", "中国工商银行",
    "621725", "中国银行",
    "621726", "浙江民泰商业银行",
    "621727", "广东南粤银行",
    "621728", "农村信用联社",
    "621730", "中国工商银行",
    "621731", "中国工商银行",
    "621732", "中国工商银行",
    "621733", "中国工商银行",
    "621734", "中国工商银行",
    "621735", "贵阳银行",
    "621738", "阳泉市商业银行",
    "621739", "长沙银行",
    "621740", "渣打银行",
    "621741", "中国银行",
    "621742", "集友银行",
    "621743", "南洋商业银行",
    "621744", "新加坡星展银行",
    "621745", "新加坡星展银行",
    "621746", "新加坡星展银行",
    "621747", "新加坡星展银行",
    "621748", "商丘银行",
    "621749", "中国工商银行",
    "621750", "中国工商银行",
    "621751", "乌鲁木齐市商业银行",
    "621752", "哈尔滨银行",
    "621753", "城市商业银行(信阳市)",
    "621754", "乌鲁木齐市商业银行",
    "621755", "三峡银行",
    "621756", "中国银行",
    "621757", "中国银行",
    "621758", "中国银行",
    "621759", "中国银行",
    "621760", "包商银行",
    "621761", "中国工商银行",
    "621762", "中国工商银行",
    "621763", "中国工商银行",
    "621764", "中国工商银行",
    "621765", "中国工商银行",
    "621766", "昆仑银行",
    "621767", "中信银行",
    "621768", "中信银行",
    "621769", "中信银行",
    "621770", "中信银行",
    "621771", "中信银行",
    "621772", "中信银行",
    "621773", "中信银行",
    "621775", "徽商银行",
    "621777", "南京银行",
    "621778", "农村信用联社",
    "621779", "农村信用联社",
    "621780", "城市商业银行(晋中市)",
    "621781", "中国工商银行",
    "621782", "中国银行",
    "621783", "南洋商业银行",
    "621784", "集友银行",
    "621785", "中国银行",
    "621786", "中国银行",
    "621787", "中国银行",
    "621788", "中国银行",
    "621789", "中国银行",
    "621790", "中国银行",
    "621791", "上海浦东发展银行",
    "621792", "上海浦东发展银行",
    "621793", "上海浦东发展银行",
    "621794", "PhongsavanhBankLimited",
    "621795", "上海浦东发展银行",
    "621796", "上海浦东发展银行",
    "621797", "邮政储蓄",
    "621798", "邮政储蓄",
    "621799", "邮政储蓄",
    "621804", "中国工商银行",
    "621807", "中国工商银行",
    "621813", "中国工商银行",
    "621814", "中国工商银行",
    "621817", "中国工商银行",
    "621901", "中国工商银行",
    "621903", "中国工商银行",
    "621904", "中国工商银行",
    "621905", "中国工商银行",
    "621906", "中国工商银行",
    "621907", "中国工商银行",
    "621908", "中国工商银行",
    "621909", "中国工商银行",
    "621910", "中国工商银行",
    "621911", "中国工商银行",
    "621912", "中国工商银行",
    "621913", "中国工商银行",
    "621914", "中国工商银行",
    "621915", "中国工商银行",
    "621977", "温州银行",
    "622002", "中国工商银行",
    "622003", "中国工商银行",
    "622004", "中国工商银行",
    "622005", "中国工商银行",
    "622006", "中国工商银行",
    "622007", "中国工商银行",
    "622008", "中国工商银行",
    "622010", "中国工商银行",
    "622011", "中国工商银行",
    "622012", "中国工商银行",
    "622013", "中国工商银行",
    "622015", "中国工商银行",
    "622016", "中国工商银行",
    "622017", "中国工商银行",
    "622018", "中国工商银行",
    "622019", "中国工商银行",
    "622020", "中国工商银行",
    "622102", "中国工商银行",
    "622103", "中国工商银行",
    "622104", "中国工商银行",
    "622105", "中国工商银行",
    "622110", "中国工商银行",
    "622111", "中国工商银行",
    "622114", "中国工商银行",
    "622126", "阜新银行",
    "622127", "农村信用联社",
    "622128", "农村商业银行",
    "622129", "农村商业银行",
    "622130", "日本三菱信用卡公司",
    "622131", "江苏银行",
    "622132", "城市商业银行(嘉兴市)",
    "622133", "贵阳银行",
    "622134", "重庆银行",
    "622135", "成都银行",
    "622136", "城市商业银行(西安市)",
    "622137", "徽商银行",
    "622138", "农村商业银行",
    "622139", "兰州银行",
    "622140", "廊坊银行",
    "622141", "城市信用联社",
    "622143", "乌鲁木齐市商业银行",
    "6221440", "TravelexCardServices",
    "6221441", "TravelexJapanKK",
    "622145", "AlliedBank",
    "622146", "青岛银行",
    "622147", "内蒙古银行",
    "622148", "上海银行",
    "622149", "上海银行",
    "622150", "邮政储蓄",
    "62215049", "邮政储蓄",
    "62215050", "邮政储蓄",
    "62215051", "邮政储蓄",
    "622151", "邮政储蓄",
    "622152", "成都银行",
    "622153", "成都银行",
    "622154", "成都银行",
    "622155", "平安银行",
    "622156", "平安银行",
    "622157", "平安银行",
    "622158", "中国工商银行",
    "622159", "中国工商银行",
    "622161", "中国光大银行",
    "622162", "九江银行",
    "622163", "北京银行",
    "622164", "TheBancorpBank",
    "622165", "包商银行",
    "622166", "中国建设银行",
    "622167", "城市商业银行(唐山市)",
    "622168", "中国建设银行",
    "622169", "农村信用联社",
    "622170", "贵阳银行",
    "622171", "中国工商银行",
    "622172", "上海银行",
    "622173", "江苏银行",
    "622176", "上海浦东发展银行",
    "622177", "上海浦东发展银行",
    "622178", "吉林银行",
    "622179", "吉林银行",
    "622181", "邮政储蓄",
    "622184", "农村信用联社",
    "622188", "邮政储蓄",
    "62218849", "邮政储蓄",
    "62218850", "邮政储蓄",
    "62218851", "邮政储蓄",
    "622199", "邮政储蓄",
    "622200", "中国工商银行",
    "622202", "中国工商银行",
    "622203", "中国工商银行",
    "622206", "中国工商银行",
    "622208", "中国工商银行",
    "622210", "中国工商银行",
    "622211", "中国工商银行",
    "622212", "中国工商银行",
    "622213", "中国工商银行",
    "622214", "中国工商银行",
    "622215", "中国工商银行",
    "622218", "农村商业银行",
    "622220", "中国工商银行",
    "622223", "中国工商银行",
    "622224", "中国工商银行",
    "622225", "中国工商银行",
    "622227", "中国工商银行",
    "622228", "上海浦东发展银行",
    "622229", "中国工商银行",
    "622230", "中国工商银行",
    "622231", "中国工商银行",
    "622232", "中国工商银行",
    "622233", "中国工商银行",
    "622234", "中国工商银行",
    "622235", "中国工商银行",
    "622236", "中国工商银行",
    "622237", "中国工商银行",
    "622238", "中国工商银行",
    "622239", "中国工商银行",
    "622240", "中国工商银行",
    "622245", "中国工商银行",
    "622246", "中国工商银行",
    "622250", "交通银行",
    "622251", "交通银行",
    "622252", "交通银行",
    "622253", "交通银行",
    "622254", "交通银行",
    "622255", "交通银行",
    "622256", "交通银行",
    "622257", "交通银行",
    "622258", "交通银行",
    "622259", "交通银行",
    "622260", "交通银行",
    "622261", "交通银行",
    "622262", "交通银行",
    "622265", "东亚银行",
    "622266", "东亚银行",
    "622267", "上海银行",
    "622268", "上海银行",
    "622269", "上海银行",
    "622270", "龙江银行",
    "622271", "农村商业银行",
    "622272", "创兴银行有限公司",
    "622273", "中国银行",
    "622274", "中国银行",
    "622275", "南昌银行",
    "622276", "上海浦东发展银行",
    "622277", "上海浦东发展银行",
    "622278", "上海银行",
    "622279", "上海银行",
    "622280", "中国建设银行",
    "622280193", "中国建设银行",
    "622281", "宁波银行",
    "622282", "宁波银行",
    "622283", "江苏银行",
    "622284", "交通银行",
    "622286", "杭州银行",
    "622287", "浙江泰隆商业银行",
    "622288", "农村信用联社",
    "622289", "农村信用联社",
    "622290", "农村信用联社",
    "622291", "柳州银行",
    "622292", "柳州银行",
    "622293", "大新银行",
    "622294", "大新银行",
    "622295", "大新银行",
    "622296", "大新银行",
    "622297", "大新银行",
    "622298", "平安银行",
    "622300", "上海银行",
    "622301", "湖州银行",
    "622302", "农村信用联社",
    "622302", "农村信用联社",
    "622303", "南京银行",
    "622303", "南京银行",
    "622304", "中国工商银行",
    "622305", "南京银行",
    "622305", "南京银行",
    "622306", "中国工商银行",
    "622307", "九江银行",
    "622307", "九江银行",
    "622308", "中国工商银行",
    "622308", "中国工商银行",
    "622309", "浙商银行",
    "622309", "浙商银行",
    "6223091100", "浙商银行",
    "6223092900", "浙商银行",
    "6223093310", "浙商银行",
    "6223093320", "浙商银行",
    "6223093330", "浙商银行",
    "6223093370", "浙商银行",
    "6223093380", "浙商银行",
    "6223096510", "浙商银行",
    "6223097910", "浙商银行",
    "622310", "青海银行",
    "622311", "齐商银行",
    "622312", "农村信用联社",
    "622313", "中国工商银行",
    "622314", "中国工商银行",
    "622315", "包商银行",
    "622315", "包商银行",
    "622316", "宁波银行",
    "622317", "中国工商银行",
    "622318", "宁波银行",
    "622319", "农村信用联社",
    "62231902", "农村信用联社",
    "622320", "农村信用联社",
    "622321", "台州银行",
    "622322", "农村商业银行",
    "622323", "农村商业银行",
    "622324", "农村信用联社",
    "622325", "汉口银行",
    "622327", "徽商银行",
    "622328", "农村商业银行",
    "622329", "农村商业银行",
    "622331", "天津银行",
    "622332", "农村商业银行",
    "622333", "东莞银行",
    "622335", "南宁市商业银行",
    "622336", "包商银行",
    "622337", "连云港市商业银行",
    "622338", "城市商业银行(焦作市)",
    "622339", "农村信用联社",
    "622340", "徽商银行",
    "622341", "农村商业银行",
    "622342", "攀枝花市商业银行",
    "622343", "农村信用联社",
    "622345", "农村商业银行",
    "622346", "中国银行",
    "622347", "中国银行",
    "622348", "中国银行",
    "622349", "南洋商业银行",
    "622350", "南洋商业银行",
    "622351", "南洋商业银行",
    "622352", "集友银行",
    "622353", "集友银行",
    "622354", "BangkokBankPcl",
    "622355", "集友银行",
    "622356", "CSC",
    "622358", "农村信用联社",
    "622359", "临沂市商业银行",
    "622360", "汇丰银行",
    "622361", "汇丰银行",
    "622362", "农村信用联社",
    "622363", "珠海华润银行",
    "622365", "东亚银行",
    "622366", "徽商银行",
    "622367", "绵阳市商业银行",
    "622368", "长沙银行",
    "622369", "农村信用联社",
    "622370", "城市商业银行(泉州市)",
    "622371", "花旗银行",
    "622372", "东亚银行",
    "622373", "大新银行",
    "622375", "大新银行",
    "622376", "恒生银行",
    "622377", "恒生银行",
    "622378", "恒生银行",
    "622379", "齐鲁银行",
    "622380", "中国银行",
    "622381", "中国建设银行",
    "622382", "中国建设银行",
    "622383", "大连银行",
    "622384", "恒丰银行",
    "622385", "大连银行",
    "622386", "上海银行",
    "622387", "永隆银行有限公司",
    "622388", "海峡银行",
    "622389", "农村信用联社",
    "622391", "潍坊银行",
    "622392", "城市商业银行(泸州市)",
    "622393", "厦门银行",
    "622394", "镇江市商业银行",
    "622395", "大同银行",
    "622396", "湖北银行",
    "622397", "宜昌市商业银行",
    "622398", "葫芦岛银行",
    "622399", "辽阳银行",
    "622400", "营口银行",
    "622402", "中国工商银行",
    "622403", "中国工商银行",
    "622404", "中国工商银行",
    "622406", "汇丰银行",
    "622407", "汇丰银行",
    "622409", "恒生银行",
    "622410", "恒生银行",
    "622411", "威海市商业银行",
    "622412", "农村信用联社",
    "622413", "鞍山银行",
    "622414", "蒙古郭勒姆特银行",
    "622415", "丹东银行",
    "622416", "兰州银行",
    "622418", "南通商业银行",
    "622420", "洛阳银行",
    "622421", "郑州银行",
    "622422", "江苏银行",
    "622423", "永隆银行有限公司",
    "622425", "哈尔滨银行",
    "622425", "哈尔滨银行",
    "622426", "天津银行",
    "622427", "台州银行",
    "622428", "宁夏银行",
    "622429", "宁夏银行",
    "622432", "大西洋银行股份有限公司",
    "622433", "新加坡大华银行",
    "622434", "澳门国际银行",
    "622435", "澳门国际银行",
    "622436", "澳门国际银行",
    "622439", "农村商业银行",
    "622440", "吉林银行",
    "622441", "城市商业银行(三门峡市)",
    "622442", "抚顺银行",
    "622442", "抚顺银行",
    "622443", "农村信用联社",
    "622444", "蒙古郭勒姆特银行",
    "622447", "江苏银行",
    "622448", "广东南粤银行",
    "622449", "金华银行",
    "622450", "金华银行",
    "622451", "大新银行",
    "622452", "农村信用联社",
    "622453", "中信银行",
    "622455", "盛京银行",
    "622456", "中信银行",
    "622459", "中信银行",
    "622462", "农村商业银行",
    "622463", "创兴银行有限公司",
    "622465", "晋商银行",
    "622466", "盛京银行",
    "622467", "广州银行",
    "622468", "上海银行",
    "622469", "农村信用联社",
    "622470", "农村信用联社",
    "622471", "东亚银行",
    "622472", "东亚银行",
    "622475", "龙江银行",
    "622476", "乌鲁木齐市商业银行",
    "622477", "农村信用联社",
    "622478", "农村商业银行",
    "622479", "中国银行",
    "622480", "中国银行",
    "622481", "农村商业银行",
    "622482", "渣打银行",
    "622483", "渣打银行",
    "622484", "渣打银行",
    "622485", "无锡市商业银行",
    "622486", "绍兴银行",
    "622487", "新加坡星展银行",
    "622487", "新加坡星展银行",
    "622488", "农村商业银行",
    "622489", "大新银行",
    "622490", "新加坡星展银行",
    "622490", "新加坡星展银行",
    "622491", "新加坡星展银行",
    "622491", "新加坡星展银行",
    "622492", "新加坡星展银行",
    "622492", "新加坡星展银行",
    "622493", "AEON信贷财务亚洲有限公司",
    "622495", "Travelex",
    "622496", "Travelex",
    "622498", "河北银行",
    "62249802", "秦皇岛银行",
    "62249804", "沧州银行",
    "622499", "河北银行",
    "622500", "上海浦东发展银行",
    "622502", "中国工商银行",
    "622504", "中国工商银行",
    "622505", "中国工商银行",
    "622506", "农村信用联社",
    "622508", "城市商业银行(六盘水市)",
    "622509", "农村信用联社",
    "622509", "农村信用联社",
    "622510", "农村信用联社",
    "622510", "农村信用联社",
    "622511", "湖北银行",
    "622513", "中国工商银行",
    "622516", "上海浦东发展银行",
    "622517", "上海浦东发展银行",
    "622517", "上海浦东发展银行",
    "622518", "上海浦东发展银行",
    "622519", "上海浦东发展银行",
    "622520", "上海浦东发展银行",
    "622521", "上海浦东发展银行",
    "622522", "上海浦东发展银行",
    "622523", "上海浦东发展银行",
    "622525", "平安银行",
    "622526", "平安银行",
    "622531", "农村商业银行",
    "622532", "晋城银行",
    "622535", "平安银行",
    "622536", "平安银行",
    "622538", "平安银行",
    "622539", "平安银行",
    "622546", "大丰银行有限公司",
    "622547", "大丰银行有限公司",
    "622548", "大丰银行有限公司",
    "622549", "哈萨克斯坦国民储蓄银行",
    "622550", "哈萨克斯坦国民储蓄银行",
    "622555", "广发银行",
    "622556", "广发银行",
    "622557", "广发银行",
    "622558", "广发银行",
    "622559", "广发银行",
    "622560", "广发银行",
    "622561", "德阳银行",
    "622562", "德阳银行",
    "622563", "德阳银行",
    "622565", "浙江泰隆商业银行",
    "622566", "汉口银行",
    "622567", "汉口银行",
    "622568", "广发银行",
    "622569", "农村商业银行",
    "622570", "中国光大银行",
    "622575", "招商银行",
    "622576", "招商银行",
    "622577", "招商银行",
    "622578", "招商银行",
    "622579", "招商银行",
    "622580", "招商银行",
    "622581", "招商银行",
    "622582", "招商银行",
    "622583", "渣打银行",
    "622584", "渣打银行",
    "622588", "招商银行",
    "622595", "南京银行",
    "622596", "南京银行",
    "622597", "中国工商银行",
    "622598", "招商银行",
    "622599", "中国工商银行",
    "622600", "中国民生银行",
    "622601", "中国民生银行",
    "622602", "中国民生银行",
    "622603", "中国民生银行",
    "622604", "中国工商银行",
    "622605", "中国工商银行",
    "622606", "中国工商银行",
    "622609", "招商银行",
    "622611", "农村商业银行",
    "622613", "重庆银行",
    "622615", "中国民生银行",
    "622616", "中国民生银行",
    "622617", "中国民生银行",
    "622618", "中国民生银行",
    "622619", "中国民生银行",
    "622620", "中国民生银行",
    "622621", "中国民生银行",
    "622622", "中国民生银行",
    "622623", "中国民生银行",
    "622625", "汉口银行",
    "622626", "汉口银行",
    "622630", "华夏银行",
    "622631", "华夏银行",
    "622632", "华夏银行",
    "622633", "华夏银行",
    "622636", "华夏银行",
    "622637", "华夏银行",
    "622638", "华夏银行",
    "622644", "龙江银行",
    "622648", "农村商业银行",
    "622650", "中国光大银行",
    "622651", "徽商银行",
    "622655", "中国光大银行",
    "622656", "交通银行",
    "622657", "中国光大银行",
    "622658", "中国光大银行",
    "622659", "中国光大银行",
    "622660", "中国光大银行",
    "622661", "中国光大银行",
    "622662", "中国光大银行",
    "622663", "中国光大银行",
    "622664", "中国光大银行",
    "622665", "中国光大银行",
    "622666", "中国光大银行",
    "622667", "中国光大银行",
    "622668", "中国光大银行",
    "622669", "中国光大银行",
    "622670", "中国光大银行",
    "622671", "中国光大银行",
    "622672", "中国光大银行",
    "622673", "中国光大银行",
    "622674", "中国光大银行",
    "622675", "中国建设银行",
    "622676", "中国建设银行",
    "622677", "中国建设银行",
    "622678", "中信银行",
    "622679", "中信银行",
    "622680", "中信银行",
    "622681", "农村信用联社",
    "622682", "农村信用联社",
    "622683", "农村信用联社",
    "622684", "渤海银行",
    "622685", "中国光大银行",
    "622686", "农村信用联社",
    "622687", "中国光大银行",
    "622688", "中信银行",
    "622689", "中信银行",
    "622690", "中信银行",
    "622691", "中信银行",
    "622692", "中信银行",
    "622693", "上海浦东发展银行",
    "622696", "中信银行",
    "622698", "中信银行",
    "622700", "中国建设银行",
    "622703", "中国工商银行",
    "622706", "中国工商银行",
    "622707", "中国建设银行",
    "622708", "中国建设银行",
    "622715", "中国工商银行",
    "622717", "浙江泰隆商业银行",
    "622722", "农村商业银行",
    "622725", "中国建设银行",
    "622728", "中国建设银行",
    "622740", "浙江民泰商业银行",
    "622750", "中国银行",
    "622751", "中国银行",
    "622752", "中国银行",
    "622753", "中国银行",
    "622754", "中国银行",
    "622755", "中国银行",
    "622756", "中国银行",
    "622757", "中国银行",
    "622758", "中国银行",
    "622759", "中国银行",
    "622760", "中国银行",
    "622761", "中国银行",
    "622762", "中国银行",
    "622763", "中国银行",
    "622764", "中国银行",
    "622765", "中国银行",
    "622766", "中信银行",
    "622767", "中信银行",
    "622768", "中信银行",
    "622770", "中国银行",
    "622771", "中国银行",
    "622772", "中国银行",
    "622775", "澳门永亨银行股份有限公司",
    "622777", "曲靖市商业银行",
    "622778", "宁波银行",
    "622785", "澳门永亨银行股份有限公司",
    "622788", "中国银行",
    "622789", "中国银行",
    "622790", "中国银行",
    "622798", "永亨银行",
    "622801", "中国光大银行",
    "622802", "农村信用联社",
    "622806", "长沙银行",
    "622806", "长沙银行",
    "622808", "农村商业银行",
    "622809", "哈尔滨银行",
    "622810", "邮政储蓄",
    "622811", "邮政储蓄",
    "622812", "邮政储蓄",
    "622813", "成都银行",
    "622815", "农村信用联社",
    "622816", "农村信用联社",
    "622817", "青海银行",
    "622818", "成都银行",
    "622820", "中国农业银行",
    "622821", "中国农业银行",
    "622822", "中国农业银行",
    "622823", "中国农业银行",
    "622824", "中国农业银行",
    "622825", "中国农业银行",
    "622826", "中国农业银行",
    "622827", "中国农业银行",
    "622828", "中国农业银行",
    "622829", "农村商业银行",
    "622830", "中国农业银行",
    "622836", "中国农业银行",
    "622837", "中国农业银行",
    "622838", "中国农业银行",
    "622839", "中国农业银行",
    "622840", "中国农业银行",
    "622841", "中国农业银行",
    "622843", "中国农业银行",
    "622844", "中国农业银行",
    "622845", "中国农业银行",
    "622846", "中国农业银行",
    "622847", "中国农业银行",
    "622848", "中国农业银行",
    "622849", "中国农业银行",
    "622851", "北京银行",
    "622852", "北京银行",
    "622853", "北京银行",
    "622855", "苏州银行",
    "622856", "桂林银行",
    "622857", "日照银行",
    "622858", "农村信用联社",
    "622859", "农村商业银行",
    "622860", "龙江银行",
    "622861", "澳门永亨银行股份有限公司",
    "622862", "澳门永亨银行股份有限公司",
    "622864", "莱芜银行",
    "622865", "吉林银行",
    "622866", "徐州市商业银行",
    "622867", "农村商业银行",
    "622868", "温州银行",
    "622869", "农村商业银行",
    "622870", "长江商业银行",
    "622871", "永亨银行",
    "622873", "江苏银行",
    "622876", "江苏银行",
    "622877", "徽商银行",
    "622878", "杭州银行",
    "622879", "徽商银行",
    "622880", "柳州银行",
    "622881", "柳州银行",
    "622882", "农村信用联社",
    "622884", "渤海银行",
    "622885", "农村商业银行",
    "622886", "烟台银行",
    "622888", "东莞银行",
    "622889", "中国工商银行",
    "622891", "农村商业银行",
    "622892", "上海银行",
    "622893", "农村信用联社",
    "622895", "农村商业银行",
    "622897", "南充市城市商业银行",
    "622898", "长沙银行",
    "622899", "温州银行",
    "622900", "长沙银行",
    "622901", "兴业银行",
    "622902", "兴业银行",
    "622902", "兴业银行",
    "622903", "中国工商银行",
    "622904", "中国工商银行",
    "622906", "农村信用联社",
    "622908", "兴业银行",
    "622909", "兴业银行",
    "622910", "中国工商银行",
    "622911", "中国工商银行",
    "622912", "中国工商银行",
    "622913", "中国工商银行",
    "622916", "中信银行",
    "622918", "中信银行",
    "622919", "中信银行",
    "622920", "日本三井住友卡公司",
    "622921", "河北银行",
    "622922", "兴业银行",
    "622926", "中国工商银行",
    "622927", "中国工商银行",
    "622928", "中国工商银行",
    "622929", "中国工商银行",
    "622930", "中国工商银行",
    "622931", "中国工商银行",
    "622932", "澳门永亨银行股份有限公司",
    "622933", "东亚银行",
    "622935", "农村信用联社",
    "622936", "承德银行",
    "622937", "德州银行",
    "622938", "东亚银行",
    "622939", "贵州银行",
    "622940", "石嘴山银行",
    "622941", "AEON信贷财务亚洲有限公司",
    "622942", "渣打银行",
    "622943", "东亚银行",
    "622944", "中国工商银行",
    "622945", "三峡银行",
    "622946", "汇丰银行",
    "622947", "农村商业银行",
    "622948", "渣打银行",
    "622949", "中国工商银行",
    "622950", "恒生银行",
    "622951", "恒生银行",
    "622952", "上海银行",
    "622953", "农村信用联社",
    "622954", "可汗银行",
    "622955", "盛京银行",
    "622957", "永亨银行",
    "622958", "永亨银行",
    "622959", "湖北银行",
    "622960", "邯郸银行",
    "622961", "贵州银行",
    "622962", "长治银行",
    "622963", "永亨银行",
    "622966", "中国建设银行",
    "622967", "赣州银行股份有限公司",
    "622968", "农村信用联社",
    "622970", "永隆银行有限公司",
    "622971", "永隆银行有限公司",
    "622972", "泰安市商业银行",
    "622973", "城市商业银行(乌海市)",
    "622974", "AEON信贷财务亚洲有限公司",
    "6229756114", "村镇银行",
    "6229756115", "村镇银行",
    "622976", "农村信用联社",
    "622977", "龙江银行",
    "622978", "鄂尔多斯银行",
    "622979", "城市商业银行(鹤壁市)",
    "622980", "城市商业银行(玉溪市)",
    "622981", "城市商业银行(西安市)",
    "622982", "张家口市商业银行",
    "622983", "平安银行",
    "622985", "上海银行",
    "622986", "平安银行",
    "622987", "上海银行",
    "622988", "中国建设银行",
    "622989", "平安银行",
    "622990", "锦州银行",
    "622991", "农村信用联社",
    "622992", "农村信用联社",
    "622993", "大连银行",
    "622994", "渣打银行",
    "622995", "村镇银行",
    "622996", "成都银行",
    "622997", "成都银行",
    "622998", "中信银行",
    "622999", "中信银行",
    "623000", "河北银行",
    "623001", "广西北部湾银行",
    "623002", "中国工商银行",
    "623003", "秦皇岛银行",
    "623006", "中国工商银行",
    "623007", "临商银行",
    "623008", "中国工商银行",
    "623010", "东莞银行",
    "623011", "中国工商银行",
    "623012", "中国工商银行",
    "623013", "农村信用联社",
    "623014", "中国工商银行",
    "623015", "中国工商银行",
    "623016", "重庆银行",
    "623017", "农村信用联社",
    "623018", "中国农业银行",
    "623019", "厦门银行",
    "623020", "华夏银行",
    "623021", "华夏银行",
    "623022", "华夏银行",
    "623023", "华夏银行",
    "623024", "新韩卡公司",
    "623025", "农村信用联社",
    "623026", "绍兴银行",
    "623027", "农村信用联社",
    "623028", "农村信用联社",
    "623029", "汉口银行",
    "623030", "朝阳市商业银行",
    "623031", "东亚银行",
    "623032", "龙江银行",
    "623033", "农村商业银行",
    "623034", "中国工商银行",
    "623035", "农村商业银行",
    "623036", "农村信用联社",
    "623037", "漯河银行",
    "623038", "农村商业银行",
    "623039", "台州银行",
    "623040", "中国银行",
    "623041", "南洋商业银行",
    "623042", "集友银行",
    "623043", "大西洋银行股份有限公司",
    "623048", "攀枝花市商业银行",
    "623051", "农村信用联社",
    "623055", "农村信用联社",
    "623057", "内蒙古银行",
    "623058", "平安银行",
    "623059", "农村信用联社",
    "623060", "承德银行",
    "623061", "杭州银行",
    "623062", "中国工商银行",
    "623063", "海峡银行",
    "623064", "大西洋银行股份有限公司",
    "623065", "农村信用联社",
    "623066", "农村信用联社",
    "623067", "金华银行",
    "623068", "城市商业银行(衡水市)",
    "623069", "大连银行",
    "623070", "大连银行",
    "623071", "农村商业银行",
    "623072", "南充市城市商业银行",
    "623073", "廊坊银行",
    "623075", "农村商业银行",
    "623076", "湖北银行",
    "623077", "日照银行",
    "623078", "恒丰银行",
    "623079", "城市商业银行(宜宾市)",
    "623081", "盛京银行",
    "62308299", "村镇银行",
    "623083", "浙江稠州商业银行",
    "623084", "城市商业银行(雅安地区)",
    "623085", "城市商业银行(泸州市)",
    "623086", "绍兴银行",
    "623087", "城市商业银行(枣庄市)",
    "623088", "农村商业银行",
    "623089", "宁夏银行",
    "623090", "农村信用联社",
    "623091", "农村信用联社",
    "623092", "农村信用联社",
    "623093", "鄂尔多斯银行",
    "623094", "中国建设银行",
    "623095", "农村商业银行",
    "623096", "重庆银行",
    "62309701", "村镇银行",
    "623098", "丹东银行",
    "623099", "抚顺银行",
    "623100", "中国工商银行",
    "623101", "德州银行",
    "623102", "威海市商业银行",
    "623103", "农村商业银行",
    "623105", "汉口银行",
    "623106", "恒生银行",
    "623107", "恒生银行",
    "623108", "盛京银行",
    "623109", "天津滨海农村商业银行股份有限公司",
    "623110", "农村商业银行",
    "623111", "北京银行",
    "623112", "温州银行",
    "623113", "华兴银行",
    "623115", "农村商业银行",
    "623116", "济宁银行",
    "62311701", "村镇银行",
    "62311702", "村镇银行",
    "62311703", "村镇银行",
    "623118", "洛阳银行",
    "623119", "齐商银行",
    "623120", "石嘴山银行",
    "623121", "城市商业银行(自贡市)",
    "62312201", "村镇银行",
    "623123", "农村商业银行",
    "623125", "农村商业银行",
    "623126", "招商银行",
    "623128", "广东南粤银行",
    "623129", "兰州银行",
    "623130", "东营银行",
    "623131", "吉林银行",
    "623132", "农村信用联社",
    "623133", "农村信用联社",
    "623135", "城市商业银行(玉溪市)",
    "623136", "招商银行",
    "623137", "德阳银行",
    "623138", "城市商业银行(驻马店市)",
    "623139", "昆仑银行",
    "62314061", "村镇银行",
    "62314062", "村镇银行",
    "623150", "长江商业银行",
    "623151", "辽阳银行",
    "623152", "城市商业银行(平顶山市)",
    "623153", "城市商业银行(乌海市)",
    "623155", "中国光大银行",
    "623156", "中国光大银行",
    "623157", "中国光大银行",
    "623158", "中国光大银行",
    "623159", "中国光大银行",
    "623160", "城市商业银行(信阳市)",
    "623161", "城市商业银行(盘锦市)",
    "623162", "农村商业银行",
    "623165", "城市商业银行(西安市)",
    "623166", "阜新银行",
    "623168", "保定银行",
    "62316901", "村镇银行",
    "62316902", "村镇银行",
    "62316903", "村镇银行",
    "62316904", "村镇银行",
    "62316905", "村镇银行",
    "62316906", "村镇银行",
    "623170", "青岛银行",
    "623171", "湖州银行",
    "623172", "大连银行",
    "623173", "大连银行",
    "62317501", "村镇银行",
    "623176", "大华银行",
    "623177", "营口银行",
    "623178", "城市商业银行(遂宁市)",
    "623179", "晋商银行",
    "623180", "铁岭银行",
    "623181", "农村信用联社",
    "623182", "甘肃银行",
    "623183", "上海银行",
    "623184", "中国银行",
    "623185", "上海银行",
    "623186", "农村商业银行",
    "623188", "鞍山银行",
    "623189", "农村商业银行",
    "623190", "农村信用联社",
    "623193", "城市商业银行(唐山市)",
    "62319563", "村镇银行",
    "623196", "泰安市商业银行",
    "623197", "晋城银行",
    "62319801", "村镇银行",
    "62319802", "村镇银行",
    "62319803", "村镇银行",
    "62319806", "村镇银行",
    "623199", "城市商业银行(凉山州)",
    "623200", "宁夏银行",
    "623201", "农村信用联社",
    "623202", "中国工商银行",
    "623203", "徽商银行",
    "623205", "城市商业银行(焦作市)",
    "623206", "中国农业银行",
    "623207", "农村商业银行",
    "623208", "中国银行",
    "623209", "杭州银行",
    "623210", "包商银行",
    "623211", "中国建设银行",
    "623213", "农村信用联社",
    "62321601", "龙江银行",
    "623218", "邮政储蓄",
    "623219", "邮政储蓄",
    "623229", "中国工商银行",
    "623250", "上海浦东发展银行",
    "623251", "中国建设银行",
    "623252", "宁波银行",
    "623255", "中国民生银行",
    "623258", "中国民生银行",
    "623259", "广发银行",
    "623260", "中国工商银行",
    "623261", "交通银行",
    "623263", "中国银行",
    "623264", "德阳银行",
    "62326501", "哈尔滨银行",
    "62326503", "龙江银行",
    "623300", "RawbankS.a.r.l",
    "623301", "中国工商银行",
    "623302", "PVBCardCorporation",
    "623303", "PVBCardCorporation",
    "623304", "PVBCardCorporation",
    "623307", "UMicrofinanceBankLimited",
    "623308", "南洋商业银行",
    "623309", "中国银行",
    "623310", "集友银行",
    "623311", "EcobankNigeria",
    "623312", "AlBarakaBank",
    "623313", "OJSCHamkorbank",
    "623314", "FidelityBankPlc",
    "623316", "CRDBBANKPLC",
    "623317", "CRDBBANKPLC",
    "623318", "东亚银行",
    "623321", "中国工商银行",
    "623323", "NongHyupBank",
    "623324", "PVBCardCorporation",
    "623325", "DavrBank",
    "623326", "KyrgyzInvestmentCreditBank",
    "623327", "KyrgyzInvestmentCreditBank",
    "623328", "中信银行",
    "623331", "StateBankofMauritius",
    "623332", "CambodiaMekongBankPL",
    "623334", "K&RInternationalLimited",
    "623335", "中国工商银行",
    "623336", "JSCATFBank",
    "623337", "JSCATFBank",
    "623338", "JSCATFBank",
    "623339", "OJSCRussianInvestmentBank",
    "623341", "NongHyupBank",
    "6233451", "JSCLibertyBank",
    "6233452", "JSCLibertyBank",
    "6233453", "JSCLibertyBank",
    "623347", "JSCLibertyBank",
    "623348", "StateBankofMauritius",
    "623350", "中国建设银行",
    "62335101", "CJSC“SpitamenBank”",
    "62335102", "CJSC“SpitamenBank”",
    "62335103", "CJSC“SpitamenBank”",
    "62335104", "CJSC“SpitamenBank”",
    "62335105", "CJSC“SpitamenBank”",
    "62335106", "CJSC“SpitamenBank”",
    "62335107", "CJSC“SpitamenBank”",
    "62335108", "CJSC“SpitamenBank”",
    "62335201", "Statebank",
    "62335202", "Statebank",
    "62335203", "Statebank",
    "6233531", "LightBank",
    "6233532", "LightBank",
    "6233533", "LightBank",
    "6233534", "LightBank",
    "6233535", "LightBank",
    "6233536", "LightBank",
    "623355", "BangkokBankPcl",
    "623357", "哈萨克斯坦国民储蓄银行",
    "623358", "韩国乐天",
    "623362", "BankofChina",
    "6233670", "LLCBank",
    "6233671", "LLCBank",
    "6233672", "LLCBank",
    "6233673", "LLCBank",
    "6233674", "LLCBank",
    "6233675", "LLCBank",
    "6233681", "OJSCTojiksodirotbank",
    "623369", "HeritageInternationalBank",
    "623370", "DESURINAAMSCHEBANKN.V.",
    "6233710", "Gazprombank",
    "6233711", "Gazprombank",
    "6233712", "Gazprombank",
    "6233720", "Gazprombank",
    "6233721", "Gazprombank",
    "6233722", "Gazprombank",
    "6233723", "Gazprombank",
    "6233730", "Gazprombank",
    "6233731", "Gazprombank",
    "6233732", "Gazprombank",
    "623375", "AdvancedBankofAsiaLtd.",
    "6233760", "Gazprombank",
    "6233761", "Gazprombank",
    "6233762", "Gazprombank",
    "623400", "中国工商银行",
    "623492", "PVBCardCorporation",
    "623493", "Co-OperativeBankLimited",
    "62349550", "CSC",
    "6234980", "LightBank",
    "6234981", "LightBank",
    "623499", "HimalayanBankLimited",
    "623500", "中国工商银行",
    "623501", "农村信用联社",
    "623504001", "村镇银行",
    "623505", "城市商业银行(三门峡市)",
    "623506", "广发银行",
    "623510", "农村商业银行",
    "623513", "韩亚银行",
    "62351501", "村镇银行",
    "623516", "农村信用联社",
    "623517001", "村镇银行",
    "623518", "龙江银行",
    "623521", "苏州银行",
    "623523", "邯郸银行",
    "623525001", "村镇银行",
    "623526", "中德住房储蓄银行",
    "62352801", "村镇银行",
    "623532001", "村镇银行",
    "623537", "宁波通商银行",
    "623539", "农村信用联社",
    "623552", "农村商业银行",
    "623555", "南洋商业银行",
    "62355701", "村镇银行",
    "62355865", "村镇银行",
    "623565", "富邦华一银行",
    "623566", "城市商业银行(哈密地区)",
    "623568", "锦州银行",
    "623569", "中国银行",
    "623571", "中国银行",
    "623572", "中国银行",
    "623573", "中国银行",
    "623574", "天津银行",
    "623575", "中国银行",
    "623577", "城市商业银行(本溪市)",
    "623578", "温州银行",
    "623579001", "村镇银行",
    "623582", "河北银行",
    "623586", "中国银行",
    "623598", "葫芦岛银行",
    "623602", "中国工商银行",
    "62360612", "村镇银行",
    "62360615", "村镇银行",
    "623607006", "村镇银行",
    "623607007", "村镇银行",
    "623607008", "村镇银行",
    "623608001", "村镇银行",
    "623608002", "村镇银行",
    "623609001", "村镇银行",
    "62361025", "村镇银行",
    "62361026", "村镇银行",
    "623611", "华兴银行",
    "623668", "中国建设银行",
    "623678353", "村镇银行",
    "623686", "邮政储蓄",
    "623688", "华兴银行",
    "623698", "邮政储蓄",
    "623699", "邮政储蓄",
    "623700", "中国工商银行",
    "623803", "中国工商银行",
    "623901", "中国工商银行",
    "624000", "中国工商银行",
    "624100", "中国工商银行",
    "624200", "中国工商银行",
    "624301", "中国工商银行",
    "624303", "中信银行",
    "624306", "CimFinanceLtd",
    "624313", "韩国乐天",
    "624320", "NongHyupBank",
    "624321", "NongHyupBank",
    "624322", "CimFinanceLtd",
    "624323", "JSCATFBank",
    "624324", "NongHyupBank",
    "624325", "NongHyupBank",
    "624329", "中国建设银行",
    "624331", "新韩卡公司",
    "624333", "韩国乐天",
    "624337", "创兴银行有限公司",
    "624338", "CambodiaMekongBankPL",
    "624341", "哈萨克斯坦国民储蓄银行",
    "6243420", "OSJCMTSBank",
    "6243421", "OSJCMTSBank",
    "6243422", "OSJCMTSBank",
    "624348", "新韩卡公司",
    "624351", "CambodiaMekongBankPL",
    "624352", "BanquePourLeCommerce",
    "624353", "BanquePourLeCommerce",
    "624354", "BanquePourLeCommerce",
    "624357", "TheBancorpBank",
    "6243650", "Gazprombank",
    "6243651", "Gazprombank",
    "6243652", "Gazprombank",
    "624402", "中国工商银行",
    "62451804", "中国工商银行",
    "62451810", "中国工商银行",
    "62451811", "中国工商银行",
    "6245806", "中国工商银行",
    "62458071", "中国工商银行",
    "625001", "台州银行",
    "625002", "越南西贡商业银行",
    "625003", "BC卡公司",
    "625004", "RoyalBankOpenStockCompany",
    "625006", "BC卡公司",
    "625007", "菲律宾RCBC",
    "625008", "创兴银行有限公司",
    "625009", "创兴银行有限公司",
    "625010", "永亨银行",
    "625011", "BC卡公司",
    "625012", "BC卡公司",
    "625013", "AlliedBank",
    "625014", "澳门商业银行",
    "625016", "澳门商业银行",
    "625017", "中国工商银行",
    "625018", "中国工商银行",
    "625019", "中国工商银行",
    "625020", "BC卡公司",
    "625021", "中国工商银行",
    "625022", "中国工商银行",
    "625023", "BC卡公司",
    "625024", "恒生银行",
    "625025", "BC卡公司",
    "625026", "恒生银行",
    "625027", "BC卡公司",
    "625028", "交通银行",
    "625029", "交通银行",
    "625031", "BC卡公司",
    "625032", "BC卡公司",
    "625033", "菲律宾BDO",
    "625034", "汇丰银行",
    "625035", "菲律宾BDO",
    "625036", "浙江民泰商业银行",
    "6250386", "RussianStandardBank",
    "6250388", "RussianStandardBank",
    "625039", "BC卡公司",
    "625040", "中国银行",
    "625042", "中国银行",
    "625044", "南洋商业银行",
    "625046", "南洋商业银行",
    "625048", "集友银行",
    "625050", "广州银行",
    "625053", "集友银行",
    "625055", "中国银行",
    "625058", "南洋商业银行",
    "625060", "集友银行",
    "625062", "永隆银行有限公司",
    "625063", "永隆银行有限公司",
    "625071", "广发银行",
    "625072", "广发银行",
    "625074", "花旗银行",
    "625075", "花旗银行",
    "625076", "花旗银行",
    "625077", "花旗银行",
    "625078", "BC卡公司",
    "625079", "BC卡公司",
    "625080", "农村商业银行",
    "625082", "兴业银行",
    "625083", "兴业银行",
    "625084", "兴业银行",
    "625085", "兴业银行",
    "625086", "兴业银行",
    "625087", "兴业银行",
    "625088", "农村商业银行",
    "625090", "龙江银行",
    "625091", "花旗银行",
    "625092", "恒生银行",
    "625093", "南洋商业银行",
    "625095", "南洋商业银行",
    "625096", "汇丰银行",
    "625098", "汇丰银行",
    "625099", "上海银行",
    "625101", "农村商业银行",
    "625103", "BC卡公司",
    "625104", "俄罗斯ORIENTEXPRESSBANK",
    "625106", "BC卡公司",
    "625107", "上海银行",
    "625110", "中国工商银行",
    "625111", "BC卡公司",
    "625112", "BC卡公司",
    "625113", "中国工商银行",
    "625114", "中国工商银行",
    "625115", "中国工商银行",
    "625116", "中国工商银行",
    "625119", "哈尔滨银行",
    "625120", "BC卡公司",
    "625123", "BC卡公司",
    "625124", "越南Vietcombank",
    "625125", "BC卡公司",
    "625127", "BC卡公司",
    "625128", "农村信用联社",
    "625129", "农村商业银行",
    "625131", "BC卡公司",
    "625132", "BC卡公司",
    "625135", "乌鲁木齐市商业银行",
    "625136", "中国银行",
    "625139", "BC卡公司",
    "625140", "中国银行",
    "625141", "中国银行",
    "625143", "中国银行",
    "625145", "中国银行",
    "625147", "澳门大丰银行",
    "625150", "农村商业银行",
    "625154", "越南Vietcombank",
    "625155", "乌鲁木齐市商业银行",
    "625156", "农村商业银行",
    "625158", "农村信用联社",
    "625160", "中国工商银行",
    "625161", "中国工商银行",
    "625162", "中国工商银行",
    "625163", "郑州银行",
    "625166", "苏州银行",
    "625170", "中国农业银行",
    "625171", "中国农业银行",
    "625172", "中国银行",
    "625174", "南洋商业银行",
    "625176", "集友银行",
    "625178", "BC卡公司",
    "625179", "BC卡公司",
    "625186", "农村商业银行",
    "625196", "大丰银行有限公司",
    "625198", "大丰银行有限公司",
    "625220", "BC卡公司",
    "625243", "BC卡公司",
    "625244", "BC卡公司",
    "625245", "BC卡公司",
    "625246", "BC卡公司",
    "625288", "农村商业银行",
    "6253098", "中国工商银行",
    "625320", "BC卡公司",
    "625330", "中国工商银行",
    "625331", "中国工商银行",
    "625332", "中国工商银行",
    "625333", "中国银行",
    "625335", "宁夏银行",
    "625336", "中国农业银行",
    "625337", "中国银行",
    "625338", "中国银行",
    "625339", "中国光大银行",
    "625350", "上海银行",
    "625351", "上海银行",
    "625352", "上海银行",
    "625353", "兴业银行",
    "625356", "兴业银行",
    "625357", "农村信用联社",
    "625359", "包商银行",
    "625360", "平安银行",
    "625361", "平安银行",
    "625362", "中国建设银行",
    "625363", "中国建设银行",
    "62536601", "青海银行",
    "62536602", "龙江银行",
    "625367", "邮政储蓄",
    "625368", "邮政储蓄",
    "625500", "农村商业银行",
    "625502", "乌鲁木齐市商业银行",
    "625503", "乌鲁木齐市商业银行",
    "625506", "农村信用联社",
    "625516", "农村商业银行",
    "625519", "农村信用联社",
    "625526", "农村商业银行",
    "625529", "宁夏银行",
    "625568", "中国银行",
    "625577", "哈尔滨银行",
    "625588", "龙江银行",
    "625598", "河北银行",
    "625650", "中国工商银行",
    "625652", "徽商银行",
    "625653", "中国农业银行",
    "625700", "徽商银行",
    "625708", "中国工商银行",
    "625709", "中国工商银行",
    "625800", "杭州银行",
    "625802", "招行信用卡支付",
    "625803", "招行信用卡支付",
    "625804", "韩国KB",
    "625805", "广发银行",
    "625806", "广发银行",
    "625807", "广发银行",
    "625808", "广发银行",
    "625809", "广发银行",
    "625810", "广发银行",
    "625814", "韩国三星卡公司",
    "625817", "韩国三星卡公司",
    "625819", "农村商业银行",
    "625823", "平安银行",
    "625825", "平安银行",
    "625826", "中国农业银行",
    "625827", "中国农业银行",
    "625828", "徽商银行",
    "625829", "BankofChina",
    "625831", "上海浦东发展银行",
    "625836", "广州银行",
    "625839", "上海银行",
    "625840", "新韩卡公司",
    "625841", "新韩卡公司",
    "625842", "KasikornBankPCL",
    "6258433", "KasikornBankPCL",
    "6258434", "KasikornBankPCL",
    "625858", "中国工商银行",
    "625859", "中国工商银行",
    "625860", "中国工商银行",
    "625865", "中国工商银行",
    "625866", "中国工商银行",
    "625888", "农村商业银行",
    "625899", "中国工商银行",
    "625900", "中国工商银行",
    "625901", "长沙银行",
    "625902", "江苏银行",
    "625903", "宁波银行",
    "625904", "韩国乐天",
    "625905", "中国银行",
    "625906", "中国银行",
    "625907", "中国银行",
    "625908", "中国银行",
    "625909", "中国银行",
    "625910", "中国银行",
    "625911", "中国民生银行",
    "625912", "中国民生银行",
    "625913", "中国民生银行",
    "625914", "中国工商银行",
    "625915", "中国工商银行",
    "625916", "中国工商银行",
    "625917", "中国工商银行",
    "625918", "中国工商银行",
    "625919", "邮政储蓄",
    "625920", "中国工商银行",
    "625921", "中国工商银行",
    "625922", "中国工商银行",
    "62592310", "中国工商银行",
    "62592320", "中国工商银行",
    "62592340", "中国工商银行",
    "625924", "中国工商银行",
    "625925", "中国工商银行",
    "625926", "中国工商银行",
    "625927", "中国工商银行",
    "625928", "中国工商银行",
    "625929", "中国工商银行",
    "625930", "中国工商银行",
    "625931", "中国工商银行",
    "625932", "中国工商银行",
    "625933", "中国工商银行",
    "625934", "中国工商银行",
    "625939", "中国工商银行",
    "625940", "大新银行",
    "625942", "中国工商银行",
    "625943", "BankofChina",
    "625944", "PhongsavanhBankLimited",
    "625946", "汉口银行",
    "625950", "包商银行",
    "625952", "哈尔滨银行",
    "625953", "上海银行",
    "625955", "中国建设银行",
    "625956", "中国建设银行",
    "625957", "上海浦东发展银行",
    "625958", "上海浦东发展银行",
    "625959", "青海银行",
    "625960", "兴业银行",
    "625961", "兴业银行",
    "625962", "兴业银行",
    "625963", "兴业银行",
    "625964", "中国建设银行",
    "625965", "中国建设银行",
    "625966", "中国建设银行",
    "625967", "华夏银行",
    "625968", "华夏银行",
    "625969", "华夏银行",
    "625970", "上海浦东发展银行",
    "625971", "上海浦东发展银行",
    "625972", "东亚银行",
    "625973", "东亚银行",
    "625975", "中国光大银行",
    "625976", "中国光大银行",
    "625977", "中国光大银行",
    "625978", "中国光大银行",
    "625979", "中国光大银行",
    "625980", "中国光大银行",
    "625981", "中国光大银行",
    "625986", "中国工商银行",
    "625987", "中国工商银行",
    "625988", "温州银行",
    "625989", "农村商业银行",
    "625993", "上海浦东发展银行",
    "625995", "天津银行",
    "625996", "中国农业银行",
    "625997", "中国农业银行",
    "625998", "中国农业银行",
    "627066", "平安银行",
    "627067", "平安银行",
    "627068", "平安银行",
    "627069", "平安银行",
    "628200", "汉口银行",
    "628201", "中国光大银行",
    "628202", "中国光大银行",
    "628203", "北京银行",
    "628204", "金华银行",
    "628205", "天津银行",
    "628206", "中信银行",
    "628207", "宁波银行",
    "628208", "中信银行",
    "628209", "中信银行",
    "628210", "江苏银行",
    "628211", "农村商业银行",
    "628212", "兴业银行",
    "628213", "贵阳银行",
    "628214", "宁夏银行",
    "628216", "交通银行",
    "628217", "东营银行",
    "628218", "交通银行",
    "628219", "桂林银行",
    "628220", "重庆银行",
    "628221", "上海浦东发展银行",
    "628222", "上海浦东发展银行",
    "628223", "上饶银行",
    "628224", "哈尔滨银行",
    "628226", "农村信用联社",
    "628227", "广西北部湾银行",
    "628228", "成都银行",
    "628229", "承德银行",
    "628230", "上海银行",
    "628231", "富滇银行",
    "628232", "农村信用联社",
    "628233", "赣州银行股份有限公司",
    "628234", "威海市商业银行",
    "628235", "农村商业银行",
    "628236", "杭州银行",
    "628237", "广东南粤银行",
    "628238", "九江银行",
    "628239", "青岛银行",
    "628242", "南京银行",
    "628248", "农村商业银行",
    "628250", "浙江稠州商业银行",
    "628251", "徽商银行",
    "628252", "内蒙古银行",
    "628253", "鄂尔多斯银行",
    "628255", "温州银行",
    "628257", "日照银行",
    "628258", "中国民生银行",
    "628259", "广发银行",
    "628260", "广发银行",
    "628261", "锦州银行",
    "628262", "招行信用卡支付",
    "628263", "兰州银行",
    "628266", "中国建设银行",
    "628267", "农村商业银行",
    "628268", "中国农业银行",
    "628269", "中国农业银行",
    "628270", "珠海华润银行",
    "628271", "商丘银行",
    "628272", "农村商业银行",
    "628273", "台州银行",
    "628275", "浙江泰隆商业银行",
    "628277", "农村信用联社",
    "628278", "乌鲁木齐市商业银行",
    "628279", "莱商银行",
    "628280", "农村信用联社",
    "628281", "长沙银行",
    "628282", "长沙银行",
    "628283", "长沙银行",
    "628284", "泰安市商业银行",
    "628285", "盛京银行",
    "628286", "中国工商银行",
    "628287", "青海银行",
    "628288", "中国工商银行",
    "628289", "农村信用联社",
    "628290", "招商银行",
    "628291", "绍兴银行",
    "628293", "柳州银行",
    "628295", "包商银行",
    "628296", "平安银行",
    "628297", "农村信用联社",
    "628299", "大连银行",
    "628300", "农村信用联社",
    "628301", "农村商业银行",
    "628302", "抚顺银行",
    "628303", "漯河银行",
    "628305", "南昌银行",
    "628306", "湖州银行",
    "628307", "农村信用联社",
    "628308", "农村商业银行",
    "628309", "辽阳银行",
    "628310", "邮政储蓄",
    "628311", "齐商银行",
    "628312", "中国银行",
    "628313", "中国银行",
    "628315", "周口银行",
    "628316", "中国建设银行",
    "628317", "中国建设银行",
    "628318", "华夏银行",
    "628319", "城市商业银行(泉州市)",
    "628321", "河北银行",
    "628322", "农村商业银行",
    "628323", "农村信用联社",
    "628326", "农村商业银行",
    "628328", "华融湘江银行",
    "628329", "丹东银行",
    "628330", "农村信用联社",
    "628331", "城市商业银行(信阳市)",
    "628332", "农村信用联社",
    "628333", "龙江银行",
    "628336", "农村商业银行",
    "628339", "城市商业银行(平顶山市)",
    "628346", "中国农业银行",
    "628351", "城市商业银行(玉溪市)",
    "628353", "阜新银行",
    "628355", "石嘴山银行",
    "628356", "甘肃银行",
    "628358", "吉林银行",
    "628359", "临商银行",
    "628360", "海峡银行",
    "628361", "城市商业银行(景德镇市)",
    "628362", "招行信用卡支付",
    "628366", "中国建设银行",
    "628367", "广州银行",
    "628368", "龙江银行",
    "628369", "农村商业银行",
    "628370", "中信银行",
    "628371", "中信银行",
    "628372", "中信银行",
    "628378", "鄂尔多斯银行",
    "628379", "齐鲁银行",
    "628380", "城市商业银行(衡水市)",
    "628381", "农村商业银行",
    "628382", "农村信用联社",
    "628385", "长安银行",
    "628386", "农村信用联社",
    "628388", "中国银行",
    "628389", "城市商业银行(驻马店市)",
    "628391", "潍坊银行",
    "628392", "农村信用联社",
    "628395", "沧州银行",
    "628397", "德州银行",
    "628398", "东莞银行",
    "6349102", "中国农业银行",
    "6353591", "中国农业银行",
    "644", "DiscoverFinancialServices，I",
    "65", "DiscoverFinancialServices，I",
    "6506", "DiscoverFinancialServices，I",
    "6507", "DiscoverFinancialServices，I",
    "6508", "DiscoverFinancialServices，I",
    "6509", "DiscoverFinancialServices，I",
    "66405512", "交通银行",
    "6649104", "交通银行",
    "6653783", "交通银行",
    "66601428", "交通银行",
    "683970", "城市商业银行(泉州市)",
    "685800", "广发银行",
    "6858000", "广发银行",
    "6858001", "广发银行",
    "6858009", "广发银行",
    "6886592", "厦门银行",
    "690755", "招商银行",
    "690755", "招商银行",
    "694301", "长沙银行",
    "69580", "南通商业银行",
    "84301", "上海浦东发展银行",
    "84336", "上海浦东发展银行",
    "84342", "上海浦东发展银行",
    "84361", "上海浦东发展银行",
    "84373", "上海浦东发展银行",
    "84380", "上海浦东发展银行",
    "84385", "上海浦东发展银行",
    "84390", "上海浦东发展银行",
    "87000", "上海浦东发展银行",
    "87010", "上海浦东发展银行",
    "87030", "上海浦东发展银行",
    "87040", "上海浦东发展银行",
    "87050", "上海浦东发展银行",
    "888", "贵阳银行",
    "900000", "中国工商银行",
    "900003", "中国民生银行",
    "900010", "中国工商银行",
    "900105", "农村信用联社",
    "90010502", "农村信用联社",
    "900205", "农村信用联社",
    "90020502", "农村信用联社",
    "90030", "中国光大银行",
    "90592", "兴业银行",
    "909810", "农村商业银行",
    "9111", "广发银行",
    "920000", "中国银行",
    "921000", "中国银行",
    "921001", "中国银行",
    "921002", "中国银行",
    "940001", "乌鲁木齐市商业银行",
    "940002", "鞍山银行",
    "940003", "锦州银行",
    "940006", "南昌银行",
    "940008", "齐鲁银行",
    "940012", "吉林银行",
    "940013", "农村商业银行",
    "940015", "天津银行",
    "940016", "广州银行",
    "940017", "南通商业银行",
    "940018", "重庆银行",
    "940020", "农村商业银行",
    "940021", "上海银行",
    "940022", "宁波银行",
    "940023", "厦门银行",
    "940025", "镇江市商业银行",
    "940026", "福州市商业银行",
    "940027", "成都银行",
    "940028", "烟台市商业银行",
    "940029", "农村信用联社",
    "9400301", "农村商业银行",
    "940031", "晋商银行",
    "940032", "城市商业银行(焦作市)",
    "940034", "恒丰银行",
    "940035", "农村商业银行",
    "940036", "杭州市农村信用社",
    "940037", "农村商业银行",
    "940038", "农村商业银行",
    "940039", "盛京银行",
    "940040", "兰州银行",
    "940041", "洛阳银行",
    "940042", "农村信用联社",
    "940043", "辽阳银行",
    "940044", "农村信用联社",
    "940045", "银川市商业银行",
    "940046", "河北银行",
    "94004602", "秦皇岛银行",
    "94004604", "沧州银行",
    "940047", "吉林银行",
    "940048", "珠海华润银行",
    "940049", "哈尔滨银行",
    "940050", "东莞银行",
    "940051", "金华银行",
    "940053", "抚顺银行",
    "940054", "葫芦岛银行",
    "940055", "宜昌市商业银行",
    "940056", "郑州银行",
    "940057", "齐商银行",
    "940058", "农村商业银行",
    "940060", "丹东银行",
    "940061", "青岛银行",
    "940062", "农村商业银行",
    "940063", "农村商业银行",
    "940065", "日照银行",
    "940066", "临沂市商业银行",
    "940068", "青海银行",
    "940069", "台州银行",
    "940070", "盐城商行",
    "940071", "长沙银行",
    "940072", "潍坊银行",
    "940073", "赣州银行股份有限公司",
    "940074", "城市商业银行(泉州市)",
    "940075", "营口市商业银行",
    "940076", "江苏银行",
    "955100", "邮政储蓄",
    "95555", "招商银行",
    "955590", "交通银行",
    "955591", "交通银行",
    "955592", "交通银行",
    "955593", "交通银行",
    "9558", "中国工商银行",
    "95595", "中国农业银行",
    "95596", "中国农业银行",
    "95597", "中国农业银行",
    "95598", "中国农业银行",
    "95599", "中国农业银行",
    "966666", "兴业银行",
    "96828", "郑州银行",
    "968807", "中信银行",
    "968808", "中信银行",
    "968809", "中信银行",
    "984301", "上海浦东发展银行",
    "984303", "上海浦东发展银行",
    "985262", "农村商业银行",
    "9896", "重庆银行",
    "990027", "汉口银行",
    "990871", "昆明商业银行",
    "998800", "平安银行",
    "998801", "平安银行",
    "998802", "平安银行",
    "999999", "华夏银行",
};

@end
