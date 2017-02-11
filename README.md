
# PrashCard
---
## “PrashCard” stands for practical flash card. This helps you greatly memorize English words in short time.
Don’t you want to concentrate on training for only words on which you haven’t felt confident yet? Using PrashCard, you can train for memorizing words by seeing your mastered level, so you can concentrate on weak points. You can use this app to memorize not only English words, but also terminology of such as medicine or information technology.
---
![alt text](./PrashCard/prash_card.gif "Logo Title Text 1")
# What you can with PrashCard
---
1. You can make card decks for flash cards.
2. You can add cards you want to memorize to card decks.
3. You can search for the meaning of an English word by accessing API service.
4. You can make training for memorizing words of card decks like playing game.
5. After a training, your mastered level is to be updated and shown by color and text on the card deck.

# Requirement for building and running the app
---
- requires swift 2.3
- requires iOS 10
- requires iPhone 6 or later models
- support only portrait view

# How to start the app
---
Just click the icon "PrashCard". You will see the top page and one sample card deck is in the list there.

# Top Page
---
1. Menu bar
  There are four items “Start”, “Beginner”, “Intermediate”, “Mastered”. These mean mastered levels of your card decks based on your trainings.
  You can move to the level of an item by clicking an item or just swipe to the left or right, then you will see the list of card decks of the level.
  Each level has its own indicating color.
  1. Start(White)
    ```
    This is the level of starting. As soon as you create a new card deck, the level for the deck is "Start". No training(challenge) has been made yet.
    ```
  2. Beginner(Red)
    ```
    Once you make challenge, and until you memorize 40% of all the cards registered in a card deck, the level stays as Beginner.
    ```
  3. Intermediate(Yellow)
    ```
    Based on your training results, more than 40% cards are completely mastered on this level. In addition, if you almost memorized 50% cards of a card deck, it is also defined as Intermediate.
    ```
  4. Mastered(Green)
    ```
    When you completely memorized all of the cards in the deck, your level is stated as Mastered.
    ```
2. Plus button
  By pushing this button, card creation view will show modally on the page. You simply input the title you want to call for the deck. You cannot create a card deck with a title which already exists.
  After proper title is input and you push OK button, a card deck is created.
  Plus button appears only when you are choosing the item Start on the menu bar.
3. Move to Card Deck
  Just after you create a card deck, there are no cards registered there. You tap the card deck item then will go on to "Card Deck" view where you can create, update or delete cards.
4. Deleting a card deck
  You can delete card deck which you think you don't need any more. Each card deck item in the list has a trash button. You can completely remove card deck by pushing the button and confirming the deletion.

# Card Deck view
---
As mentioned, you can create, update or delete cards.
1. Create
  ```
  Push the plus button on the right bottom of the view. You will see card editing view appears. You input a word you want to memorize on the area defined as "Front Side - Word". If you want to search the meaning of the card, you can search for it on API English dictionary service by pushing "Get the meaning from Online Dictionary" button. You can also input by yourself the meaning on the area "Back Side - Meaning". After you push Save button, your first card is created!
  ```

2. Update
  ```
  You can update the contents of a card in the same way as you create it. You choose a card in the deck you see and select it. Then you will see the same view with creating a card. You can make changes on the card and save it.
  ```
3. Validations
  ```
  For the future better functions I'm planing, there are some limitations in creating and amending cards.
  * You can't make two cards with the same text in front. Front text must be unique in a card deck.
  * Front side text must be equal to or shorter than 50 characters.
  * Back side text must be equal to or shorter then 300 characters.
  ```
4. Delete
  ```
  On the list of the view, you can delete a card deck list by swiping the target card to the left.   
  ```
5. CSV Export
  ```
  On the left side of the navigation bar of the view, you will find an action button. You can export all of the cards of the card deck you see on the view into a csv file. You can get the file through iTunes app share file.
  In a future release, I'm going to add a function to import from the file; however, I refrained from implementing it for the time reason regretfully.
  ```
# Training view
---
Once you create cards in a card deck, you can move into Training view. From top view, if you select a card deck, you can move to Training view this time, not to
Card deck view any more.
## Training
- Push the big button "Are you ready?".
- Card will appear one by one.
- If you memorized the card you see, you push the button "Got it!" or swipe to the right, which means you passed. If not, you push the button "Not yet..." or swipe to the left, which means you failed.
- You have only 7 seconds to do the action above. If you keep doing nothing, Count down view will appear, and it will force you to fail if you still don't swipe or push a button.
- Each card will be leveled or colored based on the following rules.
  1. Case 1: First time to challenge (Level: Start Color:White)
    ```
    If you pass, the card is leveled as Intermediate and colored Yellow.
    If you fail, the card is leveled as Beginner and colored Red.
    ```
  2. Case 2: Current level(color) -> Beginner(Red)
    ```
    If you pass, the card is leveled up to Intermediate and colored Yellow.
    If you fail, nothing is changed.
    ```
  3. Case 3: Current level(color) -> Intermediate(Yellow)
    ```
    If you pass 3 times(challenges) consecutively, the card is leveled up to Mastered(Green).
    If you fail 3 times consecutively, the card is leveled down to Intermediate.
    ```
  4. Case 4: Current level(color) -> Mastered(Green)
    ```
    If you pass, nothing is changed.
    If you fail, the card will is leveled down to Intermediate.
    ```
- You can always check your level(color) on the top area of the view. There shows information of you past training result.
- If you push the hamburger icon on the right of the navigation bar, you can open a submenu titled "Card Deck Menu".

# Card Deck Menu
---
Here you can arrange the training method or move to Card Deck view to edit cards.
## Target(Filtering)
```
You can filter your cards as you check. For example, if you train for only red cards, you check only Red check button.
This function will make your training more effective for sure.
You can return to Training view by tapping the background dark area.
```
### Actions
1. Shuffle cards
  By pressing this item, you can shuffle your cards randomly and go back to training in that condition.

2. Edit cards
  As the title, you can go to Card deck view to edit cards.
