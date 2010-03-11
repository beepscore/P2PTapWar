//
//  P2PTapWarViewController.h
//  P2PTapWar
//
//  Created by Chris Adamson on 6/9/09.
//  Copyright Subsequently and Furthermore, Inc. 2009. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#define AMIPHD_P2P_SESSION_ID @"amiphd-p2p"
#define TIME_KEY @"time"
//START:code.P2PTapWarViewController.protocolkeys
#define START_GAME_KEY @"startgame"
#define END_GAME_KEY @"endgame"
#define TAP_COUNT_KEY @"taps"
//END:code.P2PTapWarViewController.protocolkeys
#define WINNING_TAP_COUNT 50

@interface P2PTapWarViewController : UIViewController <GKSessionDelegate, GKPeerPickerControllerDelegate> {

	GKSession *gkSession;

	UIBarButtonItem *startQuitButton;
	UILabel *playerTapCountLabel;
	UILabel *opponentTapCountLabel;
	
	NSString *opponentID;
	BOOL actingAsHost;
	UInt32 playerTapCount;
	UInt32 opponentTapCount;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *startQuitButton;
@property (nonatomic, retain) IBOutlet UILabel *playerTapCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *opponentTapCountLabel;


-(IBAction) handleStartQuitTapped;
-(IBAction) handleTapViewTapped;

@end

