# WorkReceipts App
An app that allows to you to painlessly track and send your receipts.


## Table of Contents
- [Light & Dark modes](#Light-&-Dark-modes)
- [Card with receipts](#Card-with-receipts)
- [Custom camera](#Custom-camera)
- [Exporting photos](#Exporting-photos)
- [Exporting receipts as PDF](#Exporting-receipts-as-PDF)
- [Custom Onboarding](#Custom-Onboarding)
- [License](#License)


## Light & Dark modes
| Light | Dark |
| ---- | ---- |
| <img src="https://user-images.githubusercontent.com/56613736/90426883-a9c43080-e0b9-11ea-95cc-c94d7f1416fd.PNG" align="center" height=500px/> | <img src="https://user-images.githubusercontent.com/56613736/90426887-aaf55d80-e0b9-11ea-95ff-eea8ba9d0137.PNG" align="center" height=500px/> |


## Card with receipts

<img src="https://user-images.githubusercontent.com/56613736/90426656-55b94c00-e0b9-11ea-916f-84127e1cbc3c.gif" align="right" height=500px/>

This app approaches a minimalistic look with powerful features.

There are 2 main categories: 

- **Pending** - tab shows payments paid by you but the company has not paid you back yet.

- **Claimed** - tab shows the expenses received back from the company.

Receipts can be filtered by `Newest date`, `Oldest date` and `First letter`.

Also, `searchbar` is available to find the receipt places

<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />


## Custom camera

<img src="https://user-images.githubusercontent.com/56613736/90442076-f3207a00-e0d1-11ea-9608-7c7b3d849778.gif" align="left" height=500px/>

`Custom camera view` with a fluid openning animation.

Animation is done by masking the view using navigation controller transition.

When openning a camera a choice to select from Photo library is available.

<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />


## Exporting photos

<img src="https://user-images.githubusercontent.com/56613736/90426643-4f2ad480-e0b9-11ea-93cc-b66367ae1bdd.gif" align="right" height=500px/>

When pressing `email button` at the top left of the main view the selection appears in the card. You can select receipts individually or use `Select All`/`Unselect all` button at the bottom.

Choosing `Photos only` option will present the user with the gallery of the selected images.

Then, the user can either send all the photos using Gmail, Outlook, WhatsApp or any other app that allows you to send files.

Photos can be send all in once or as a zip archive (thanks to marmelroy/Zip)

<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />


## Exporting receipts as PDF

<img src="https://user-images.githubusercontent.com/56613736/90426612-4508d600-e0b9-11ea-8f4c-564ef0bb609a.gif" align="left" height=500px/>

When pressing email button at the top left of the main view the selection appears in the card. You can select receipts individually or use Select All/Unselect all button at the bottom.

Choosing `PDF (Table & photos)` option will present the user with a PDF preview.

When exporting receipts as a PDF, the table is also added with all selected receipts.<br/>
Creation of the table is done with a help of my framework [SimplePDFBuilder](https://github.com/MaksBelenko/SimplePDFBuilder)



<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />
<br />

## Custom Onboarding

Custom onboarding was created to show how to use the app.

| Welcome | After first receipt is added |
| ---- | ---- |
| <img src="https://user-images.githubusercontent.com/56613736/90444570-fc134a80-e0d5-11ea-93dc-30533e427b1c.gif" align="center" height=500px/> | <img src="https://user-images.githubusercontent.com/56613736/90444943-b73be380-e0d6-11ea-9dfa-8e18e3aa775e.gif" align="center" height=500px/> |


## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2020 © <a href="https://github.com/MaksBelenko" target="_blank">MaksBelenko</a>.


