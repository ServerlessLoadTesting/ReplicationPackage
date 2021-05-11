# Replication Package
The replication package for our manuscript _A Case Study on the Stability of Performance Tests for Serverless Applications_ consists of two parts:
* [Automated measurement harness for the airline booking case study](#Automated-measurement-harness-for-the-airline-booking-case-study)
* [Collected measurement data and analysis scripts required to reproduce all results/figures from the paper](#Measurement-data-and-analysis-scripts)

## Automated measurement harness for the airline booking case study
The Airline Booking application is a fully serverless web application that implements the flight booking aspect of an airline on AWS ([GitHub](https://github.com/aws-samples/aws-serverless-airline-booking)). Customers can search for flights, book flights, pay using a credit card, and earn loyalty points with each booking. The airline booking application was the subject of the [AWS Build On Serverless](https://pages.awscloud.com/GLOBAL-devstrategy-OE-BuildOnServerless-2019-reg-event.html) series and presented in the AWS re:Invent session [Production-grade full-stack apps with AWS Amplify](https://www.youtube.com/watch?v=DcrtvgaVdCU).

### System Architecture
The frontend of the serverless airline is implemented using CloudFront, Amplify/S3, Vue.js, the Quasar framework, and stripe elements. 
This frontend sends queries to five backend APIs, as shown in figure below: 
<p align="center">
<img src="https://github.com/ServerlessLoadTesting/ReplicationPackage/blob/main/images/serverlessairline.png?raw=true" width="800">
</p>

_Search Flights_, _Create Charge_, _Create Booking_, _List Bookings_, and _Get Loyalty_. The five APIs are implemented as GraphQL queries using AWS AppSync, a managed GraphQL service. 
The _Search Flights_ API retrieves all flights for a given date, arrival airport and departure airport from a DynamoDB table using the DynamoDB GraphQL resolver. 
The _Create Charge_ API places a charge on a credit card using Stripe, a SaaS payment provider. An API gateway triggers the execution of the _ChargeCard_ Lambda function, which manages the call to the stripe API. 
The _Create Booking_ API reserves a seat on a flight, creates an unconfirmed booking, and attempts to collect the charge on the customer's credit card. If successful, it confirms the booking in a DynamoDB table, and awards loyalty points to the customer. In case the payment collection fails, the reserved seat is freed again, and the booking is canceled. This workflow is implemented as an AWS Step Functions workflow that coordinates the Lambda functions _ReserveBooking_, _CollectPayment_, _ConfirmBooking_, _NotifyBooking_, _CancelBooking_, and _RefundPayment_. The functions _ReserveBooking_ and _CancelBooking_ directly modify DynamoDB tables. The _NotifyBooking_ function publishes a message to SNS, which is later consumed by the _IngestLoyalty_ function that updates the loyalty points in a DynamoDB table. The _CollectPayment_ and _RefundPayment_ functions trigger via an API Gateway the execution of functions from the Serverless Application Repository that manage the calls to the stripe backend.

The _List Bookings_ API retrieves the existing bookings for a customer. Similarly to the _Search Flights_ API, this is implemented using a DynamoDB table and the DynamoDB GraphQL resolver. Finally, the _Get Loyalty_ API retrieves the loyalty level and loyalty points for a customer. An API Gateway triggers the Lambda function _FetchLoyalty_, which retrieves the loyalty status for a customer from a DynamoDB table.

### Changelog
### Workload

## Measurement data and analysis scripts
