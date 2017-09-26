# hack-a-thing-2-thenuttyprofessor
hack-a-thing-2-thenuttyprofessor created by GitHub Classroom


For this Hack-A-Thing we built a barcode scanner iOS app that with the idea that it would be able scan a barcode, pull the ingredients from a food product and look for any allergens or dietary restrictions that a users opts for. 
How this app works now is pretty bare bones due to two main constraints: time and lack of a good free upc database. Because of this we're using the walmart database so only items that are available at walmart are scannable. Also right now it only scans items and gives a pop-up alert with the item's name.
We mostly worked together on this app, but Ross took the lead during the initial creation of the barcode scanner and api calls, while Kyra too the lead during the parsing of the JSON. 

It has a bug where the barcode gets scanned and the alert comes up before the api call gets processed so you have to scan items twice for them to work.
Overall it was a pretty cool project that we would potentially be interested in extending in the future.
