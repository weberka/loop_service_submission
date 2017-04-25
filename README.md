# Case Study: Loop Service

Aire’s Virtual Interview application collects information from consumers directly. While this information is valuable, Aire is aware that there may also be trends and behaviour across multiple applications that may affect a particular application.

https://d2mxuefqeaa7sj.cloudfront.net/s_852AF94CBE5D63E87F3F215B3AF9F77CD993B638A9A73935405338CFC24E4E6E_1483529320557_file.png


*The Aire Virtual Interview*

But more immediately, Aire wants to keep track of interesting and emerging behaviour across a stream of applications in order to manage potential fraud risk and generate insight.

As such, Aire wants to create a new service called *Loop* which monitors the realtime stream of applications and watches for emerging behaviour of interest to Aire.

# Brief

We are all really excited about implementing Loop, and everyone is interested in the different insights that the service could give us. Below you’ll see a list of ideas that could be potentially implemented — however, being an agile start-up we have to make tough choices and need to start with the opportunity that we believe will add the most business value.

# Working on the problem

Please limit your time to 6 hours. Pick an approach and problem that you feel comfortable getting done in that time. If you don’t finish it within 6 hours, that is totally acceptable. While having working and complete solutions is nice, we are more interested in seeing your thinking than a complete solution.

This means we’re particularly interested in the questions you asked and decisions you made along the way, and your journey to get there. So please show your working!

Feel free to use any technology or language that you are most comfortable with. As long as you give us instructions on how to run your solution (include anything we need to install first) then we’ll be happy 😊. Through we would like the complete source code (of course) so that we can see and understand your implementation.

# Events

We believe all of these events are interesting, so which one(s) you explore is up to you. Though you are of course welcome to discuss your ideas with us!

| **Event Name**      | **Description**                                                                                                                                                                     |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| INCREASE_HIGH_RISK  | We are seeing an increase from an established baseline of applications containing high risk features. Please tell us how you define a high risk features (or talk to us about it!). |
| NEW_GEO             | We have seen an application from a new geography previously unseen. Please tell us how you define a geographical area (or talk to us about it!).                                    |
| EXAGGERATED_INCOME  | We are seeing applications that are exaggerating their income.                                                                                                                      |
| INCREASE_GEO        | We’re seeing more applications from a geography than we’ve seen previously. Please tell us how you define a geographical area (or talk to us about it!).                            |
| SEASONAL_VARIATION  | A significant and, ideally, unexpected change in the number of applications over time.                                                                                              |
| SIMILAR_APPLICATION | The loan application is a close duplicate of a previous application. Fraudsters may submit a number of similar applications in a relatively short period of time.                   |

# Requirements

We fully understand that the Loop Service is a big problem and there a lot of different things that you could work on, including different bits of functionality and different parts of the stack. The challenge is to choose the part of the problem that you are going to work on and try to make simplifying assumptions about the bits you won’t have time to work on. Our hope is that you can pick the piece of the problem and the technology to provide the solution that gives you the best opportunity to shine and show us your strengths.

By this stage of the conversation it will be clear that we’d like to see your work with an engineering focus or a data science focus — but please get in touch if not! Of course drop us a line if there are any questions at all about the challenge; we really want this to be a collaborative process.

## Engineering case study
Goal: to to build v0.1 of the Loop service. This minimally viable version should detect at least one event.

- The service needs to adhere to a defined REST API. See the Materials section for more on the nature of this API.
- The service will be polled for relevant events by one other interested party.
- For the purpose of this case study, the service does not need to “remember” anything between being stopped and starting again.
- This is designed to be a production service, so please approach it as you would any production-ready system.
- Automated tests are always nice 😋

## Data science case study
Goal: to use the data set to make the case for what we build first for Loop.

- We’ll want to present your proposal to the management team and demonstrate that your findings are worth implementing, so it’s important that you identified a way of delivering business value — or at least obtained insights leading us towards this.
- The team will also want to understand how you evidenced your proposal through the analysis that you’ve done. (For guidance, think a thorough analysis notebook shared between colleagues rather than a PowerPoint presentation.)
- Then the engineering team will want to plan to deploy your proposal into production, so they will need to have a well-defined proposal. A working prototype would be great if you can get that far, though of course use any language or libraries that you are comfortable with.

# Materials

We have made available a public Git repository as a starting point for you. To clone the repo

    git clone git@github.com:AireLabs/loop_service.git

**NOTE**: The repo is pretty big, so please download over wifi unless you have a massive data pack.

- The repo contains a *baseline* dataset of past applications. In the data science case study, you should treat this as a training set.
- It contains a second, *stream* dataset containing a representative stream of new applications. Unlike baseline, stream has no information on loan performance or the loan terms that were given to the applicant as it models the data available before making a decision to lend.
- There’s a data dictionary in `LCDataDictionary.xlsx` that describes the fields in the dataset, though please ask if anything’s unclear.
- There are also a few utilities for sending data to the service and retrieving events from it, as well as an example dummy service to demonstrate how it could work. Feel free to ignore these if you’re not tackling the engineering version of this problem!
- The data are adapted from [Lending Club’s publicly available dataset](https://www.lendingclub.com/info/download-data.action), and contains loan applications and their associated performance to date. (Note that we have changed some of the data.)
- The baseline file contains fields on loan repayment performance to date. As these will not be available for new applicants, these are not present in the stream file.

## Engineering case study dummy service

**Using the example Loop service**
To run the example service, you need to be using Python 3. This will start the example service on port 5000.


    pip install -r requirements.txt
    bin/start_example_service

To run the tests


    bin/run_tests

**Useful utilities**
Given an HTTP endpoint, this will send all applications piped on stdin

    echo "[{}]" | bin/submit_apps http://127.0.0.1:5000/apps

Shows an example of how to create lots of applications from a CSV file and pipe them to a service.

    bin/submit_lots_of_apps http://127.0.0.1:5000/apps

**HINT**: csvkit is your friend 😛

This utility retrieves any pending events

    bin/get_events http://127.0.0.1:5000/events

The REST API is fairly straightforward

- All post operations contain a JSON body with the request defined.
- All `Content-Type` headers should be set to `application/json`
- There are two endpoints: `/apps` and `/events`
- You submit apps by posting to `/apps`
- The body of the post request is an array of dictionaries
- Each dictionary in the array represents an application `[{"name_1"="value_1", ..., "name_n"="value_n"}, ..., app_m]`
- You retrieve outstanding events by getting `/events`

Though obviously see the code base for concrete examples.

## Data science case study notes

**Loan performance and risk**
The baseline dataset contains a grade, which is approximately how risky the application was judged (how likely it was that the applicant would fail to repay). While this will not always be predictive, it may be a useful indicator in the absence of loan performance data.

**Using other datasets**
We believe you should be able to make significant progress using only the data provided to you. However, you are welcome (but certainly not required!) to integrate other data sources if you feel they add value. If you do include other sources, please provide details in your notebook or accompanying documentation.

# Deliverables

Please deliver a zip archive with a Git repository which contains your solution. Feel free to make commits in your copy of the repository we have supplied.

## Engineering

An `OVERVIEW.md` that explains

- How to run your service, feed it data and retrieve interesting events
- How to run your automated tests
- Anything we need to have installed as prerequisite to use your service
- What limitations to be aware of in your implementation — and why these are acceptable
- A proposed roadmap for continued improvement. Please explain what, when, and why

## Data science

If not part of a notebook, an `OVERVIEW.md` that explains

- How to reproduce your analysis, feed it data and run any models you’ve built to identify interesting events
- Anything we will need to have installed as prerequisite to run your code
- Which events you chose and why you feel these deliver significant value
- What assumptions you made when choosing them
- What limitations to be aware of in your implementation — and why these are acceptable
- A proposed roadmap for continued improvement. Please explain what, when, and why

# Talk to us!

While this is a homework exercise, we don’t want you to do this alone! We’d love to talk to you as you’re working through the exercise so we can understand how you work and of course answer any questions you may have.

- Once you’ve had a chance to read this and maybe have a quick look at the Git repo, we’d like to have a quick chat with you about the problem, scope, and any questions you may have.
- It would also be great to review your work after you’ve finished, discuss processes you followed, any mistakes you made 😛, and possibly the next steps you’d like to take.
- Please also get in touch with us at any point during the exercise if you have more questions on anything here. We’d be delighted if we spoke to you once or twice (or maybe more!) as you worked through the problem.

# 🍰
