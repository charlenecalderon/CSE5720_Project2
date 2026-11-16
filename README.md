# CSE 5720 Project 1 — Case 6

## Local Food Rescue and Distribution Network

### Project Overview

This PostgreSQL database supports a local food-rescue network that connects food donors with partner sites. The database stores donors, food categories, food offers, partner sites, drivers, pickups, allocations, and deliveries. It is designed to help coordinators track available food, distribute offers across partner sites, monitor delivered quantities, and identify partially allocated or unclaimed offers.

The database also includes an `allocation_summary` view that shows each food offer, its original quantity, and the total quantity currently allocated.

### Setup and Execution Order

Create or connect to an empty PostgreSQL database, then run the SQL files in this order:

1. `01_schema.sql`  
2. `02_data.sql`  
3. `03_queries.sql`  
4. `04_verification.sql`

### Results

After running `01_schema.sql` and `02_data.sql`, the database should contain:

| Table | Expected Rows |
| :---- | ----: |
| donor | 5 |
| food\_category | 6 |
| partner\_site | 5 |
| driver | 5 |
| food\_offer | 15 |
| allocation | 23 |
| pickup | 10 |
| delivery | 20 |

The seed data includes the required Case 6 edge cases, including an unclaimed offer, partially allocated offers, expired offers, repeat donors, and a high-volume partner site.

`03_queries.sql` contains the five required Case 6 queries:

- Q1: Lists unclaimed, unexpired food offers with donor, category, quantity, and use-by date.  
- Q2: Shows deliveries with donor, food category, driver, partner site, and delivered quantity.  
- Q3: Calculates total delivered quantity for each partner site.  
- Q4: Shows donors whose delivered quantity exceeds 100 units.  
- Q5: Finds offers whose allocated quantity is less than the offered quantity using a CTE.

`04_verification.sql` contains six intentional constraint-rejection tests:

- B1: Rejects an offer quantity of zero.  
- B2: Rejects an allocation referencing a nonexistent food offer.  
- B3: Rejects a duplicate food-offer/partner-site allocation.  
- B4: Rejects an invalid pickup status.  
- B5: Rejects a use-by date earlier than the donation date.  
- B6: Rejects a negative delivered quantity.

When the schema and seed data are loaded correctly, the verification script should report six PASSED notices and then roll back the intentional test operations.

The verification file also checks three client scenarios:

1. Food offers that still have quantity available for allocation.  
2. Total completed deliveries received by each partner site.  
3. Unclaimed and expired food offers that require coordinator attention.

Additional checks make sure the test data does not allocate or deliver more food than it should.

### Assumptions and Design Decisions

- All names and transaction data are fabricated and are used only for testing.  
- An unclaimed offer is defined as a food offer with no allocation rows assigned to a partner site.  
- Only deliveries with a status of `delivered` are counted in completed-delivery totals.  
- Dates in the seed data use `CURRENT_DATE` so expiration and upcoming-offer examples remain relative to the date the scripts are run.  
- A food offer may be split between multiple partner sites through the `allocation` table.  
- Individual allocation quantities must be positive.  
- The current database does not automatically stop total allocations from going over the amount offered. Instead, the verification file checks for that problem.

### How the Database Helps the Client

The database gives food-rescue coordinators one organized place to track food offers from donors and how those offers are distributed to partner sites. Coordinators can identify food that has not yet been claimed, see how much of an offer remains available, review delivery activity, and compare the amount of food received by different partner sites.

The required queries also support management decisions. Staff can identify offers that still need allocation, determine which sites are receiving the most food, identify high-contributing donors, and find partially allocated offers that still have food available. The verification script provides evidence that important database constraints reject invalid data and that the supplied test data supports the required client scenarios.

### Team Contributions

| Team Member | Contribution |
| :---- | :---- |
| Alexander Morse | Debugging and code organization, writing this readme |
| Charlene Calderon | Created tables, Presentation, help with debugging and running tests |
| Rofael Ibrahim | Generated much of the original code found 03 and 04 |
| Kevin Olea | Debugging, writing the report |
| Amro Srouji | Generated static data |

## AI Provenance

This is our AI usage section. Every section below provides the exact AI disclosure specification the project explicitly asks for.

### Tools

ChatGPT, Gemini

### Tasks

Most of our knowledge stems from using commands to somehow view data that is already given to us \- as that is the information that is focused on being taught in the course. Generating tables and creating data is not our strongsuit. So after we tried it ourselves, we asked ChatGPT to fix our data to ensure it contains just enough data to work with to satisfy the requirements.&nbsp;

I used Gemini to check my logic on Query 5 after we were having problems. After attempting to fix we still had the same problem until we asked Gemini to check our logic. It said our logic was fine just that it should be on top because SQL syntax requires it to be on top to create a CTE.&nbsp;

### Prompts

\-Here is our database our group created and our project requirements file (we are doing case 6 only). Can you list modifications we should add to our database to ensure we can fulfill all of the requirements listed? Ensure to give line numbers and which files need to be modified. \[included files for ChatGPT to view\]

\- Can you check to see if our CTE query is correct

### Verification

We ensured valid syntax was being offered, alongside of typing the actual code ourselves and running it to test its function. We also verified the info given and adapted the code to meet the project's specifications.

After clarifying the placements and also giving us tips to simplify our code we typed it in. It ran fine after that.&nbsp;

### Members responsible for verification

Alex verified the first prompt's suggestions.