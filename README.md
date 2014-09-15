## Welcome to Instacab Client

Instacab is an iPhone app used to request cars, messengers and anything else much like Uber, with real-time progress tracking on the map, integrated payment and receipt after your ride or request is completed.

## This is What It Looks Like
<img src="./readme/request.png" alt="Request Screen" style="width:200px">
<img src="./readme/confirmation.png" alt="Confirmation Screen" style="width:200px">
<img src="./readme/pickup_location.png" alt="Choosing Manual Pickup Location" style="width:200px">
<img src="./readme/fare_quote.png" alt="Fare Quote" style="width:200px">
<img src="./readme/progress.png" alt="Waiting For Pickup" style="width:200px">
<img src="./readme/receipt.png" alt="Receipt" style="width:200px">
<img src="./readme/feedback.png" alt="Feedback" style="width:200px">

## Getting Started

1. Checkout Instacab source at the command prompt if you haven't yet:

        git checkout https://github.com/tisunov/InstacabClient

2. At the command prompt, install required Cocapods packages:

        pod install

3. Open InstaCab.xcworkspace to build and run the app
4. Register your Google Maps API key
5. (Optionaly) Register your Mixpanel key for analytics
6. (Optionaly) Register your BugSnag key for crash reporting
7. Start Instacab Node.js Dispatcher
8. Start Instacab Rails Backend

## Setting Up Dispatcher

Please refer to [InstacabDispatcher](https://github.com/tisunov/InstacabDispatcher/)

## Setting Up Backend

Please refer to [Instacab](https://github.com/tisunov/Instacab/)

## TODO

- [ ] Write unit tests
- [ ] Remove Payture Payment Processor integration
- [ ] Cache remote images using Path's [FastImageCache](https://github.com/path/FastImageCache)
- [ ] Translate or remove Russian comments
- [ ] Validate promo code upon sign up
- [ ] Remove ReactiveCocoa dependency
- [ ] Consider ditching WebSockets in favor REST API, we are updating whole app state anyways.