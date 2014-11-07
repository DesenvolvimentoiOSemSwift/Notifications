//
//  AppDelegate.swift
//  Push
//
//  Created by Alexandra Aguiar on 08/09/14.
//  Copyright (c) 2014 Alexandra Aguiar. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //necessário para integração com o Parse
        //Parse.setApplicationId("COLOQUE_SEU_APP_ID", clientKey: "COLOQUE_SEU_CLIENT_KEY")
        Parse.setApplicationId("3e5QSnX9dhGj2O70IOYq75GGhRe3toCFY1cP2DYU", clientKey: "CsAAmiq1wkY670gR905Qbj8tp1lsJXBFvX4y5HK2")

        
        //registra uma ação
        var acceptAction = UIMutableUserNotificationAction()
        acceptAction.identifier="ACCEPT_IDENTIFIER"
        acceptAction.title="ACCEPT"
        acceptAction.activationMode = UIUserNotificationActivationMode.Background
        acceptAction.destructive = false
        acceptAction.authenticationRequired = false
        
        //registra uma ação
        var declineAction = UIMutableUserNotificationAction()
        declineAction.identifier="DECLINE_IDENTIFIER"
        declineAction.title="DECLINE"
        declineAction.activationMode = UIUserNotificationActivationMode.Background
        declineAction.destructive = false
        declineAction.authenticationRequired = false
        
        //registra uma categoria
        var inviteCategory = UIMutableUserNotificationCategory()
        inviteCategory.identifier="INVITE_CATEGORY"
        inviteCategory.setActions([acceptAction,declineAction], forContext: UIUserNotificationActionContext.Default)
        inviteCategory.setActions([acceptAction,declineAction], forContext: UIUserNotificationActionContext.Minimal)
        
        var cat = NSMutableSet()
        cat.addObject(inviteCategory)

        //cria as configurações das notificações dessa aplicação
        let notificationTypes:UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let notificationSettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: cat)
        
        //chama o método para escalonamento da notificação local.
        //scheduleLocalNotif()
        
        var locMan = CLLocationManager()
        locMan.delegate = self //deve conformar com CLLocationManagerDelegate
        locMan.requestWhenInUseAuthorization()
        
        
        //registra as notificações
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        
        return true
    }


    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            startShowingLocationNotifications()
        }
    }
    
    func startShowingLocationNotifications(){
        var localNotif = UILocalNotification()
        localNotif.alertBody="Chegou!"
        localNotif.regionTriggersOnce = true

        // Set-up a region
        let latitude:CLLocationDegrees = -30.060351;
        let longitude: CLLocationDegrees = -51.175527;
        let region = CLCircularRegion(center: CLLocationCoordinate2DMake(latitude, longitude), radius: 10, identifier: "PUCRS")
        
        localNotif.region = region
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        var region = notification.region
        if((region) != nil){
            println("Voce chegou no lugar!")
        }
    }
    
    /*funções necessárias para notificações locais*/
    //função chamada para tratar uma ação disparada a partir de uma notificação (local neste caso)
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        if (identifier == "ACCEPT_IDENTIFIER"){
            println("Aceitar!")
        }else{
            println("Declinar!")
        }
        
        //tem que chamar o completion no final
        completionHandler()
    }
    
    
    //função que cria uma notificação local
    func scheduleLocalNotif(){
        var localNotif = UILocalNotification()
        localNotif.alertBody="Teste de notificação"
        localNotif.alertAction = "Titulo informativo"
        localNotif.soundName = UILocalNotificationDefaultSoundName
        localNotif.category = "INVITE_CATEGORY"
        localNotif.fireDate = NSDate().dateByAddingTimeInterval(10)//in seconds
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
    /*funções necessárias para notificações locais*/

    
    
    /*função utilizadas para notificações remotas*/
    //função necessária para registro de notificações remotas
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        var allowedTypes = notificationSettings.types
        UIApplication.sharedApplication().registerForRemoteNotifications()

    }
    
    //função chamada em caso de sucesso no registro do token remoto
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("Got Token! My token is ",deviceToken)
        
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    //função chamada em caso de falha no registro do token remoto
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to get token ",error)
    }
    
    //função chamada em caso de recebimento de uma notificação remota de usuário
    func application(application: UIApplication!, didReceiveRemoteNotification userInfo:NSDictionary!) {
        
        println("Got push notif!")
    }
    
    //função chamada em caso de recebimento de uma notificação remota silenciosa
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        println("Got silent notif")
        
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    /*função utilizadas para notificações remotas*/

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

