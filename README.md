# Parallel MapReduce
Multi-threaded API for mapping and reducing large datasets. Final Project for Data Mining at Carleton College, by Charlie Imhoff and Ben Withbroe.

> If you’d prefer to manually compile any element of the Swift project, you can open the project file in Xcode 8+. There are multiple build configurations setup, for building the framework, unit tests, and KNN app.

## Product: `MapReduce` Framework
A `MapReduce` framework is the core of our project. It provides a generic, multi-threaded implementation of the standard MapReduce programming paradigm.

## Product: `MapReduceTests` Unit Tests
A series of unit tests for our `MapReduce` framework are packaged in our Xcode project. Running these tests checks the accuracy and speed of our framework’s core functions. The unit tests profile the actual runtime of our functions across multiple iterations (to reduce noise).

We used these unit testing tools heavily in understanding the performance of our functions across many use cases.

## Product: `KNN` App
This app has been compiled and an application has been provided for convenience. It can be run like any other macOS application, simply by opening it.

This application allows the user to run KNN via brute force or by utilizing our `MapReduce` framework. The KNN program comes bundled with a set of the handwritten digit data from HW1 and uses those for training and test data.

> The KNN app isn’t a terminal program because our framework is non-static, and due to current ABI instability in Swift, terminal executables can’t embed dynamic frameworks.