//
//  P2PTapWarViewController.m
//  P2PTapWar
//
//  Created by Chris Adamson on 6/9/09.
//  Copyright Subsequently and Furthermore, Inc. 2009. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import "P2PTapWarViewController.h"

@implementation P2PTapWarViewController

@synthesize startQuitButton, playerTapCountLabel, opponentTapCountLabel;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark game logic
//START:code.P2PTapWarViewController.updatetapcountinithostandjoingame
-(void) updateTapCountLabels {
	playerTapCountLabel.text =
		[NSString stringWithFormat:@"%d", playerTapCount];
	opponentTapCountLabel.text =
		[NSString stringWithFormat:@"%d", opponentTapCount];
}

-(void) initGame {
	playerTapCount = 0;
	opponentTapCount = 0;
}

-(void) hostGame {
	[self initGame];
	NSMutableData *message = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
		initForWritingWithMutableData:message];
	[archiver encodeBool:YES forKey:START_GAME_KEY];
	[archiver finishEncoding];
	NSError *sendErr = nil;
	[gkSession sendDataToAllPeers: message
			withDataMode:GKSendDataReliable error:&sendErr];
	if (sendErr)
		NSLog (@"send greeting failed: %@", sendErr);
	// change state of startQuitButton
	startQuitButton.title = @"Quit";
	[message release];
	[archiver release];
	[self updateTapCountLabels];
}

-(void) joinGame {
	[self initGame];
	startQuitButton.title = @"Quit";
	[self updateTapCountLabels];
}
//END:code.P2PTapWarViewController.updatetapcountinithostandjoingame

//START:code.P2PTapWarViewController.endgamemethods
-(void) showEndGameAlert {	
	BOOL playerWins = playerTapCount > opponentTapCount;
	UIAlertView *endGameAlert = [[UIAlertView alloc]
		initWithTitle: playerWins ? @"Victory!" : @"Defeat!"
		message: playerWins ? @"Your thumbs have emerged supreme!":
			@"Your thumbs have been laid low"
		delegate:nil
		cancelButtonTitle:@"OK"
		otherButtonTitles:nil];
	[endGameAlert show];
	[endGameAlert release];
}

-(void) endGame {
	opponentID = nil;
	startQuitButton.title = @"Find";
	[gkSession disconnectFromAllPeers];
	[self showEndGameAlert];
}
//END:code.P2PTapWarViewController.endgamemethods


#pragma mark UI event handlers

//START:code.P2PTapWarViewController.handlequittapped
-(IBAction) handleStartQuitTapped {
	if (! opponentID) {
		actingAsHost = YES;
		GKPeerPickerController *peerPickerController =
			[[GKPeerPickerController alloc] init];
		peerPickerController.delegate = self;
		peerPickerController.connectionTypesMask =
			GKPeerPickerConnectionTypeNearby;
		[peerPickerController show];
	}
}
//END:code.P2PTapWarViewController.handlequittapped

//START:code.P2PTapWarViewController.handleviewtapped
-(IBAction) handleTapViewTapped {
	playerTapCount++;
	[self updateTapCountLabels];
	// did we just win?
	BOOL playerWins = playerTapCount >= WINNING_TAP_COUNT;
	// send tap count to peer
	NSMutableData *message = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver =
		[[NSKeyedArchiver alloc] initForWritingWithMutableData:message];
	[archiver encodeInt:playerTapCount forKey: TAP_COUNT_KEY];
	if (playerWins)
		[archiver encodeBool:YES forKey:END_GAME_KEY];
	[archiver finishEncoding];
	GKSendDataMode sendMode =
		playerWins ? GKSendDataReliable : GKSendDataUnreliable;
	[gkSession sendDataToAllPeers: message withDataMode:sendMode error:NULL];
	[archiver release];
	[message release];
	// also end game locally
	if (playerWins) 
		[self endGame];
}
//END:code.P2PTapWarViewController.handleviewtapped

#pragma mark GKPeerPickerControllerDelegate methods

//START:code.P2PTapWarViewController.sessionforconnectiontype
-(GKSession*) peerPickerController: (GKPeerPickerController*) controller 
		  sessionForConnectionType: (GKPeerPickerConnectionType) type {
	if (!gkSession) {
		gkSession = [[GKSession alloc]
			 initWithSessionID:AMIPHD_P2P_SESSION_ID
			 displayName:nil
			 sessionMode:GKSessionModePeer];
		gkSession.delegate = self;
	}
	return gkSession;
}
//END:code.P2PTapWarViewController.sessionforconnectiontype


- (void)peerPickerController:(GKPeerPickerController *)picker
			  didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
	NSLog ( @"connected to peer %@", peerID);
	[session retain]; 	 // TODO: who releases this?
	[picker dismiss];
	[picker release];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	NSLog ( @"peer picker cancelled");
	[picker release];
}


#pragma mark GKSessionDelegate methods

//START:code.P2PTapWarViewController.peerdidchangestate
- (void)session:(GKSession *)session peer:(NSString *)peerID
	didChangeState:(GKPeerConnectionState)state {
    switch (state) 
    { 
        case GKPeerStateConnected: 
			[session setDataReceiveHandler: self withContext: nil]; 
			opponentID = peerID;
			actingAsHost ? [self hostGame] : [self joinGame];
			break; 
    } 
}
//END:code.P2PTapWarViewController.peerdidchangestate


//START:code.P2PTapWarViewController.didreceiveconnectionrequestfrompeer
- (void)session:(GKSession *)session
		didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	actingAsHost = NO;
}
//END:code.P2PTapWarViewController.didreceiveconnectionrequestfrompeer

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog (@"session:connectionWithPeerFailed:withError:");	
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog (@"session:didFailWithError:");		
}

# pragma mark receive data from session

/* receive data from a peer. callbacks here are set by calling
 [session setDataHandler: self context: whatever];
 when accepting a connection from another peer (ie, when didChangeState sends GKPeerStateConnected)
 */
//START:code.P2PTapWarViewController.receivedatafrompeerinsessioncontext
- (void) receiveData: (NSData*) data fromPeer: (NSString*) peerID
		   inSession: (GKSession*) session context: (void*) context {
	NSKeyedUnarchiver *unarchiver =
		[[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	if ([unarchiver containsValueForKey:TAP_COUNT_KEY]) {
		opponentTapCount = [unarchiver decodeIntForKey:TAP_COUNT_KEY];
		[self updateTapCountLabels];
	}
	if ([unarchiver containsValueForKey:END_GAME_KEY]) {
		[self endGame];
	}
	if ([unarchiver containsValueForKey:START_GAME_KEY]) {
		[self joinGame];
	}
	[unarchiver release];
}
//END:code.P2PTapWarViewController.receivedatafrompeerinsessioncontext



#pragma mark vc methods

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/
- (void)viewDidLoad {
    [super viewDidLoad];
 }

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end