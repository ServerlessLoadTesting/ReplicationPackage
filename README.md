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

_Search Flights_, _Create Charge_, _Create Booking_, _List Bookings_, and _Get Loyalty_. The five APIs are implemented as GraphQL queries using AWS AppSync, a managed GraphQL service. The _Search Flights_ API retrieves all flights for a given date, arrival airport and departure airport from a DynamoDB table using the DynamoDB GraphQL resolver. 
The _Create Charge_ API places a charge on a credit card using Stripe, a SaaS payment provider. An API gateway triggers the execution of the _ChargeCard_ Lambda function, which manages the call to the stripe API. The _Create Booking_ API reserves a seat on a flight, creates an unconfirmed booking, and attempts to collect the charge on the customer's credit card. If successful, it confirms the booking in a DynamoDB table, and awards loyalty points to the customer. In case the payment collection fails, the reserved seat is freed again, and the booking is canceled. This workflow is implemented as an AWS Step Functions workflow that coordinates the Lambda functions _ReserveBooking_, _CollectPayment_, _ConfirmBooking_, _NotifyBooking_, _CancelBooking_, and _RefundPayment_. The functions _ReserveBooking_ and _CancelBooking_ directly modify DynamoDB tables. The _NotifyBooking_ function publishes a message to SNS, which is later consumed by the _IngestLoyalty_ function that updates the loyalty points in a DynamoDB table. The _CollectPayment_ and _RefundPayment_ functions trigger via an API Gateway the execution of functions from the Serverless Application Repository that manage the calls to the stripe backend. The _List Bookings_ API retrieves the existing bookings for a customer. Similarly to the _Search Flights_ API, this is implemented using a DynamoDB table and the DynamoDB GraphQL resolver. Finally, the _Get Loyalty_ API retrieves the loyalty level and loyalty points for a customer. An API Gateway triggers the Lambda function _FetchLoyalty_, which retrieves the loyalty status for a customer from a DynamoDB table.

### Changelog
We have made the following changes to the original system:
* As with any of the three case studies, we wrapped every function with the resource consumption metrics monitoring and generated a corresponding DynamoDB table for each function where the monitoring data is collected.
* Configured step functions workflow as an express workflow to reduce execution cost
* The Stripe API test mode has a concurrency limit of 25 requests. After contacting the support, we adapted the application to distribute the requests to the StripeAPI across multiple Stripe keys.
* Reconfigured the Stripe integration to timeout and retry long-running requests, which significantly reduced the number of failed requests.
* We requested an increase of the Lambda concurrent executions service quota from the default of 1.000 to 5.000.
* Implemented caching for SSM parameters to reduce the number of requests to the System Manager Parameter Store.
* Enabled the higher throughput option of the System Manager Parameter Store.

### Workload
For this case study, we configured the following user behavior:
1. Search for a flight
2. Place a charge on a credit card using [Stripe](https://stripe.com/)
3. Book a flight
4. List booked flights
5. Display loyalty points

The experiments are configured in the form of measurement plans that specify memory size of the functions, the experiment duration, the request rate, number of experiment repetitions, and the number of threats the load driver uses. The following example measurement plan configures an experiment with memory size of 1024 MB, an experiment duration of 600 seconds, 200 requests/second with 128 threats for the load driver that is repeated 10 times.

```
{
   "name":"1024MB",
   "branch":"1024MB",
   "duration":600,
   "load":200,
   "repetitions":10,
   "loadriverthreats":128
}
```

The measurement plans in [TODO](TODO) contain the experiment configuration used for our first dataset. To configure other experiment setups, simply adapt the measurement plans in [TODO](TODO) before building the docker container (see [here](#Replicating-our-measurements)).

### Replicating our measurements

## Measurement data and analysis scripts
