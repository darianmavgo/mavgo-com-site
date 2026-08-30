---
title: villageboardgame
layout: project
dataKey: villageboardgame
---

In 2009 and some of 2010, I built a board game modeled after a downsized Monopoly board. I'm also adding the google sheets that contains all the settings for each spot on the village board. As of May 30 2022 I'm hosting it at https://www.mavgo.com/portfolio/kenya
The original board matched the 40 spaces of the original Monopoly design.  I downsized the board to 20 spaces to better fit on the screen at the time.  
# Found
* Found!! The original javascript to control update of the board. It's contained in the html file kenya_inline.html. Thanks again to https://archive.org/ for preserving older versions of VillagetheGame.com.
* the fish, the bear, and pig gif I used as the original 3 players is gone probably, now in the assets folder.
* Deeds table google sheet.  I've committed it as csv. This details the all properties of each space on the Village board.  
* Cards table google sheet.  I've committed it as csv.  This details all the cards that can happen during gameplay.  
* Village globals google sheet. I've committed it as csv. I created a sheet that javascript feeds into a globals object and uses throughout gampeplay.  
* Courtesy of Internet Archive I found the slightly butchered original prototype html, committed to this project as kenya.html. 

# Still Missing 
* js file that leverages google sheets to feed in all the config data. 

# Functionality
* Only single player or multiplayer with people taking turns on the same computer.  
* No server-side persistence.  Reloading the page completely resets the game.  All progress gets lost.  
* No secrets for a given player.  Since it's share the computer style there's no secrets between players.
* Control panel on the side that allowed for lots of cheats for quick testing of any new game rule.


* To restore the original gameplay, we simply need to update the image links to assets/image.gif instead of the previous path.  
# How to change images for each tile
Add image URL in each object in monopoly.js
In techopoly\client\src\Card.js uncomment backgroundImage on line 26, and comment backgroundImage on line 30
Comment the paragraph on line 37
<p style={{textAlign:'center',width:'100%',position:"absolute",marginTop:"40px",fontWeight:"600",padding:"10px"}}>{this.props.store.game.board[this.props.position].name}</p>
In terminal go to techopoly\client and run the command npm run build
------------------------------------------------------------------------------------------------------------------------------------------------
Then check the boxes, if the image does not show then add height and width of div on line 23. again run the command npm run build
