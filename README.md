# Seat Wizard - Seat Management Application For SalesForce

<img src="https://i.ibb.co/wNngN6y/Seat-Wizard.png" alt="Seat-Wizard" border="0">

Seat Management and Booking App enables the user to manage seats and seat booking in Salesforce.
The App implements Salesforce Lightning Design System (SLDS) and utilizes Lightning Web Components. The App can be used both on Desktop and on Mobile.

Admin User can create seats and rooms by drawing on a Canvas with the organization floor as a background, using Rectangle tool or a "Sticky-Line" tool.
After a seat is drawn Admin User can set the seat attributes based on predetermined values.

End Users can book a seat for a day, multiple days, hour/s, based on the organization preferences (managed by Metadata). End Users can search for co-workers' booking and manage their own bookings by using the relevant tabs.

## Getting Started

1. Install our [Package](#Packages) in your Org. The package is Unmanged, to allow full transperancy.

2. Set up workdays, workhours and other settings in the "Settings" Metadata record under "FloorManager" (Setup -> Custom Metadata Types -> FloorManager -> Settings).

3. Assign Admin permissions to admin users with Permission Set "MapManagerBuilder" (Setup -> Permission Sets -> MapManagerBuilder -> Manage Assignments).

4. Create Seats - from App Launcher (9 dots menu), search for "Seat Wizard", click on "Builder" tab, choose a floor from the "Floors" picklist.

5. Pick a drawing tool using the "Tools" Bar and draw a shape, saving with either Ctrl+S or the save icon under "Drawing" Bar.

6. Set the Seat Name, Type, Attributes and assign to a neighborhood. Save and Publish ("Publish" button). You just created your new Seat/s.

7. Click the "Seat Reservations" tab, choose a floor and a date. You will be able to see your Seat on the map's image, clickable and ready for use.

## Use Seat Wizard on Community

To use the Seat Wizard in your Saleforce's community, add the "Lwc_appLuncher" Lightning Web Component to your chosen page.

## Diagram of Seat Wizard's Objects Relationships.

<img src="https://i.ibb.co/2KD5bPN/sw-relationships.jpg" alt="sw-relationships" border="0">

## Documentation

Lightning Web Components used in Seat Wizard.

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
| 1.10 | [Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t4K000002akfO) | Updated edit mode for seat drawing - sticky and rect Improved UI experience Improved mobile support.
| 1.9 | [Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t4K000002akMd) | Initial Release.


## HowTo

We included video tutorials for your use to understand how to use our Seat Wizard

-   [Drawing A Seat](https://youtu.be/dUHZp_S3qBc)
-   [Edit A Seat](https://youtu.be/k6LCeM774Fc)
-   [Making A Day Reservation](https://youtu.be/oKTlGP8OnrU)
-   [Making A Hour Reservation](https://youtu.be/a8RG6yzMp5w)

## About Us

-   **Who are we?**

    Seat Wizard was made by [Pelleg Maimon](https://www.linkedin.com/in/pelleg-maimon-81853aa7/) and [Orchay Naeh](https://www.linkedin.com/in/orchay-naeh-93144b65/). We are both Salesforce developers located in Israel and working in our respective companies. Hoping to offer a tool useful for companies to support the Hybrid Model for working from the office and home. 


## Kudos

-   **Thank you [Shay Ozer](https://www.linkedin.com/in/shay-ozer-65018b18/) for providing a helping hand and guidance with creation of this tool.**
