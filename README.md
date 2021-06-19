# Seat Management Application For SalesForce

<img src="https://i.ibb.co/wNngN6y/Seat-Wizard.png" alt="Seat-Wizard" border="0">

Draw seats on jpeg maps of your organization's floors, setting up the type, attributes and neighborhoods for seats,meeting rooms and etc.

"builders" can draw on an uploaded image: seats,rooms and etc. Making this application reusable for multiple scenarios and needs. Users can make reservations based on the "builders" drawings, search for other coworkers's reservations and managed their reservatrions under "My Reservations" tab for ease of use.

Using Custom Metadata Type for configurations of workdays,workhours and number of weeks available for reservations to suit the company's work schedule.

With Javascript's [Canvas](https://www.w3schools.com/html/html5_canvas.asp) we allow "builders" to draw shapes using 2 tools we built: "Rectangle" and "Sticky Line", accessible through the "Builder" tab, to any user with the permission set.

Seat Wizard implement Salesforce Lightning Design System (SLDS) and developed using Lightning Web Components and was built to work on both mobile and desktop views.

## Getting Started

1. Install our Package in your Org [Lightning Web Components Dev Guide](#Packages), the package is an Unmanged package, to allow full transperanty for you to check and validate that this app is indeed safe for your org.

2. Set up workdays,workhours and other settings in the "Settings" metadata record under "FloorManager" (Setup -> Custom Metadata Types -> FloorManager -> Settings). 

3. Assign admin to "builder" with Permission set "MapManagerBuilder" (Setup -> Permission Sets -> MapManagerBuilder -> Manage Assignments).

4. go to the App Launcher (9 dots menu), search for "Maps", click on "New" to create a Floor, giving the record a name and the url for the floor's image (recommendation: use static resources).

5. Go to the App Launcher (9 dots menu), search for "Seat Wizard", click on "Builder" tab, choose a floor from the "Floors" picklist.

6. Pick a drawing tool using the "Tools" Bar and draw a shape, saving with either Ctrl+S or the save icon under "Drawing" Bar.

7. Give the saved drawing a Name,Type,Attributes and assign to a neighborhood, saving and finally press on the "Publish" button, to save your drawing's configuarions as a seat.

8. Move to the "Seat Reservations" tab, choose a floor and a date, once the map will load, you will be able to see your drawing on the map's image, clickable and ready for use.

## Use Seat Wizard on Community

Use the Seat Wizard in your Saleforce's community, by adding to your chosen page inside the community the lwc component called "Lwc_appLuncher". 

## Diagram of Seat Wizard's Objects Relationships.

<img src="https://i.ibb.co/2KD5bPN/sw-relationships.jpg" alt="sw-relationships" border="0">

## Documentation

Lightning Web Components and Apex classes used in Seat Wizard.

|**Component**| **Description**| **Comment**|
| ------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| c-lwc-app-luncher | Contains `c-holding-tabs` component and visible for pages, tabs and community | Used for placing the Seat Wizard on a veraity of pages, tabs or in the community.
| c-holding-tabs | Manages tabs , contains `c-reservation-wizard`,`c-map-builder` and `c-my-seat-reservations` | `c-map-builder` accessible only for users who has the "MapManagerBuilder" permission.
| c-reservation-wizard | Used for Reservations. |
| c-map-builder | Used for creating Seats. |
| c-my-seat-reservations | Used to review and delete personal reservations. |
| c-seat-reservation-card | Used for showing single reservations in `c-my-seat-reservations`. |
| c-seat-section | Used for searching for reservations. |
| c-sw-custom-lookup | A component used for looking up for Users. |
| c-map-builder-seat-card | Used by `c-map-builder` for saved drawing|
| c-drawing-tool-menu | Used by `c-map-builder`, responsible for drawing operations | Available Options: Tools-> Select drawing Tool. Zoom-> Zoom In/Out. Drawing -> Save/Delete Drawing.
| c-lwc-modal | A modal component. | 
| c-canvas-artist | Responsible for managing all the canvas operations. | 

## Packages

We provide an unmanaged package for ease of use:

|**Package Version**| **Url**| **Comment**|
| ------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| 1.9 | [Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t4K000002akMd) | This is the first public package for Seat Wizard available for download.


## HowTo

We included video tutorials for your use to understand how to use our Seat Wizard

-   [Drawing A Seat](https://youtu.be/dUHZp_S3qBc)
-   [Edit A Seat](https://youtu.be/k6LCeM774Fc)
-   [Making A Day Reservation](https://youtu.be/oKTlGP8OnrU)
-   [Making A Hour Reservation](https://youtu.be/a8RG6yzMp5w)

## About Us

-   **Who are we?**

    This Application was made by [Pelleg Maimon](https://www.linkedin.com/in/pelleg-maimon-81853aa7/) and [Orchay Naeh](https://www.linkedin.com/in/orchay-naeh-93144b65/). We are both Salesforce developers located in Israel and working in our respective companies. Hoping to offer a tool useful for companies to support the Hybrid Module for working from the office and home. 


## Kudos

-   **Thank you Shay Ozer for providing a helping hand and guidance with creation of this tool.**
