# HelperLibrary

Rondinelli Morais

[@rondmorais](https://twitter.com/rondmorais)

rondinellimorais@gmail.com

## Overview ##

The HelperLibrary framework is a simple iOS static library that contains all work

A framework HelperLibrary é uma iOs static library simples que contem toda a implementação do trabalho bobo e repetitivo que você tem que fazer toda vez que cria um novo projeto iOs/OSX.

HelperLibrary contem uma classe principal chamada `UtilHelper.h` que é recheada de trabalho bobo que venho adicionando desde que comecei a trabalhar com iOS SDK. Abaixo está uma lista resumida das coisas que podemos fazer com HelperLibrary:

- Criar uma representação `UIColor` a partir do código RGB
- Calcular a altura de um terminado texto (Usado bastante em células dinâmicas de tabelas)
- Truncar uma string em um determinado tamanho
- Monitorar o estado da internet e receber uma notificação através de block
- Verificar se o dispositivo possui uma conexão ativa com a internet
- Converte o Token do Push Notification em `NSString`
- Salvar um arquivo
- Marcar um arquivo salvo como No-Backup (Arquivo que não deve ser copiando na sincronização do iCloud)
- Converter `NSDate` em `NSString` ou virse-versa
- Converter `NSDate` em `NSTimeInterval` ou virse-versa
- Criar um `NSDictionary` a partir de uma Query string
- E muito mais...

## Generate .framework ##

Para gerar o arquivo .framework é super simples, basta selecionar o alvo `Framework`, conforme a imagem abaixo:

<div style="float: right"><img src="http://rondinelliharris.xpg.uol.com.br/images/framework_target.png" /></div>

e compilar o projeto (⌘+B).

Ao fazer isso HelperLibrary irá criar o pacote `HelperLibrary.framework` em `${PROJECT_DIR}`:
<div style="float: right"><img width="70%" src="http://rondinelliharris.xpg.uol.com.br/images/generate_framework.png" /></div>

## Usage ##

To use the HelperLibrary classes within your application, simply include the core framework header using the following:

    #import <HelperLibrary/HelperLibrary.h>

## Basic use ##

##### Monitorar o estado da internet #####

```objective-c
[[UtilHelper sharedInstance] internetConnectionNotification:^(NetworkStatus remoteHostStatus, BOOL isCurrentState) {
       
      switch (remoteHostStatus) {
          case NotReachable:
              NSLog(@"no connection!");
              break;
          case ReachableViaWiFi:
              NSLog(@"Connected via Wifi");
              break;
          case ReachableViaWWAN:
              NSLog(@"Connected via mobile data");
              break;
          default:
              break;
      }
  }];
```
Esse block será chamado toda vez que o estado da internet mudar.

##### Converter `UIView` to `UIImage` #####

```objective-c
// create view
UIView * snoopfyView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {400, 400}}];
[snoopfyView setBackgroundColor:rgb(218, 218, 255)];// using rgb function in UtilHelper

// create my image of the chicken Leg
UIImageView * chickenLegImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chickenleg"]];

// centralize
chickenLegImageView.center = snoopfyView.center;

// add my imageview into my view
[snoopfyView addSubview:chickenLegImageView];

// converte my view to UIImage
// Now, only send to Post Facebook Wall
UIImage * sharedImage = [UtilHelper imageWithView:snoopfyView];
```

##### Using SQLite database #####

Você pode usar a classe `DBConfigDefault` para gerenciar seu banco .sqlite3

Os métodos `managerContext` e `managerContextWithDelegate:` são responsáveis por gerenciar todo o processo chato de copiar o arquivo .sqlite3 para o diretório Document/.Private, rodar os arquivos de atualizações (Veja mais na documentação de `DBConfigDefault`) e atualizar a versão do banco. Sua aplicação será notificada através do delegate `dbConfigDefaultDidUpdatedDatabase:newVersion:` se caso houve uma atualização na versão do banco.

```objective-c
// static function into UtilHelper.h
NSLog(@"%@", privateDirectory());

// Copy database in bundle to privateDirectory()
// If exists file of update, execute!
[DBConfigDefault managerContext];
```

Com Delegate:

```objective-c
@interface AppDelegate () <DBConfigDefaultDelegate>
@end

// static function into UtilHelper.h
NSLog(@"%@", privateDirectory());

// Copy database in bundle to privateDirectory()
// If exists file of update, execute!
[DBConfigDefault managerContextWithDelegate:self];

#pragma mark - DBConfigDefaultDelegate
- (void)dbConfigDefaultDidUpdatedDatabase:(CGFloat)oldVersion newVersion:(CGFloat)newVersion {
    if(newVersion > oldVersion){
        NSLog(@"now I'm using a new version of database!");
    }
}

```

##### Extensions #####

`UIAlertView` with block:

```objective-c
[[[UIAlertView alloc] initWithTitle:@"Do you wanna close this page?"
                              message:nil
                        completeBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            NSLog(@"%i", (int)buttonIndex);
                        }
                    cancelButtonTitle:@"Cancel"
                    otherButtonTitles:@"I'm", @"No"] show];
```

`NSDictionary` with override get values

```objective-c
NSDictionary * values = @{ @"number" : @"141",
                               @"name" : @"Rondinelli Morais",
                               @"items" : [NSMutableArray arrayWithObjects:@"Product1", @"Product2", @"Product3", @"Product4", nil]
                             };
    

    // using extension NSDictionary
    NSLog(@"My number is: %i", (int)[values integerForkey:@"number"]);
    NSLog(@"My name is: %@", [values stringForKey:@"name"]);
    NSLog(@"My products is: %@", [values mutableArrayValueForKey:@"items"]);
```

See more list extensions below:
  - UIAlertView
  - NSObject
  - NSDictionary
  - UIView
  - UIDevice
  - NSData
  - NSData
  - NSDate
  - UIImage
  

##### Download Image #####

Fazer o download de imagem dinâmicamente certamente é uma tarefa chata. Você pode utilizar a classe `DownloadManager` para fazer o download de qualquer imagem e manter uma cache em seu aplicativo:

```objective-c
NSURL * URL = [NSURL URLWithString:@"https://avatars0.githubusercontent.com/u/3987557?v=3&s=460"];
    
// Download the image and create cache
[[DownloadManager sharedInstance] imageWithURL:URL completeBlock:^(UIImage *image) {
    NSLog(@"Done!");
    NSLog(@"%@", image);
}];
```

Após a conclusão do download, o cache da imagem é mantido no diretório `/Library/Caches/Images`.

## Generate documentation Apple ##

O projeto foi documentado utilizando o padrão de documentação appledoc. Para gerar a documentação escolha o alvo `Documentation`, conforme a imagem abaixo:

<div style="float: right"><img src="http://rondinelliharris.xpg.uol.com.br/images/documentation.png" /></div>

e compilar o projeto (⌘+B).

Ao fazer isso HelperLibrary irá criar um diretório `documentation` em `${PROJECT_DIR}` contendo todo HTML da documentação:
<div style="float: right"><img width="70%" src="http://rondinelliharris.xpg.uol.com.br/images/documentation_2.png" /></div>

A documentação também ficará disponível em `Documentation and API Reference (⇧⌘0)` do XCode.

## Included Libraries ##
  - [FMDB](https://github.com/ccgus/fmdb)
  - [NSData (CommonCrypto)](https://github.com/AlanQuatermain/aqtoolkit/tree/master/CommonCrypto)
  - [NSData (Base64)](https://github.com/l4u/NSData-Base64)
  - [NSDate] (https://github.com/belkevich/nsdate-calendar)
  - [UIImage](https://github.com/kishikawakatsumi/CropImageSample/blob/master/CropImageSample/UIImage%2BUtilities.h)
  - [UIDevice](https://github.com/InderKumarRathore/UIDeviceUtil)
