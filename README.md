# RijksDataBrowser

A simple sample application that displays information about art objects from the Rijksmuseum API.  

## Stack

The app is built with Swift, UIKit, Combine, and MVVM. Underlying logic is represented with higher-level Repositories and lower-level Services.  

## TODO
 - Add image caching;
 - Add prefetching on the `ArtObjectsOverview` screen;
 - Fix the dynamic layout of self-sizing cells on `ArtObjectsOverview` screen. `UICollectionView` doesn't really like cells that are sized by auto layout and tend to break the layout occasionally;
 - Remove code duplication in image loader error handling code;
 - Extract all the UI constants into an injectable design system;
 - Cover the rest of the app logic with tests;
 - Wrap `UIImageView` with a custom type, so the logic layer doesn't tkow anything about `UIKit`.
