with 
vote_counts as (
    select
      bills.bill_id
      ,bills.anti_pro
      ,bills.category as category
      ,people.people_id as people_id
      ,sum (case when vote_desc = 'Yea'then 1 else 0 end) as yea
      ,sum (case when vote_desc = 'Absent'then 1 else 0 end) as absent
      ,sum (case when vote_desc = 'Nay'then 1 else 0 end) as nay
      ,sum (case when vote_desc = 'NV'then 1 else 0 end) as non_voting
      ,sum (case when vote_desc = 'Yea'then 1 else 0 end) as votes_for
      ,sum (case when vote_desc in ('Nay','NV','Absent') then 1 else 0 end) as votes_against
      ,sum (case when vote_desc in ('Yea','Nay','NV','Absent') then 1 else 0 end) as total_votes
    FROM `dxplegislativescorecard-416017.Il_OH_2023_2024.people` as people
    LEFT JOIN `dxplegislativescorecard-416017.Il_OH_2023_2024.votes` as votes USING (people_id)
    LEFT JOIN `dxplegislativescorecard-416017.Il_OH_2023_2024.rollcalls` as rollcalls USING (roll_call_id)
    LEFT JOIN `dxplegislativescorecard-416017.Il_OH_2023_2024.bills` AS bills USING (bill_id)
    where bills.bill_id in (1641768, 1670728, 1681863, 1754878, 1685650, 1687189, 1767656, 1771828, 1697754, 1774630, 1711614, 1713119, 1785126, 1765787, 1711175, 1723919, 1711236, 1778017, 1695099, 1696434, 1699553, 1703971, 1740608)
    group by bills.anti_pro, bills.category, bills.bill_id, people.people_id
  ),
votes_rollup as (
  select
    people_id
    ,category
    ,sum(case when anti_pro = 'pro-trans' then votes_for else 0 end) as pro_trans_votes_for
    ,sum(case when anti_pro = 'anti-trans' then votes_against else 0 end) as pro_trans_votes_against
    ,sum(case when anti_pro = 'anti-trans' then votes_for else 0 end) as anti_trans_votes_for
    ,sum(case when anti_pro = 'pro-trans' then votes_against else 0 end) as anti_trans_votes_against
    ,sum(total_votes) as total_votes
    ,sum(case when category = 'bathroom'then total_votes else 0 end) as bathroom_votes
    ,sum(case when category = 'education'then total_votes else 0 end) as education_votes
    ,sum(case when category = 'healthcare'then total_votes else 0 end) as healthcare_votes
    ,sum(case when category = 'military'then total_votes else 0 end) as military_votes
    ,sum(case when category = 'social'then total_votes else 0 end) as social_votes
    ,sum(case when category = 'sports'then total_votes else 0 end) as sports_votes
  from vote_counts
  group by category, people_id
),
category_rollup as (
  select
    people_id
    ,sum(pro_trans_votes_for + pro_trans_votes_against) as pro_trans_votes
    ,sum(anti_trans_votes_for + anti_trans_votes_against) as anti_trans_votes
    ,sum(total_votes) as total_votes
    ,sum(bathroom_votes) as bath_votes
    ,sum(education_votes) as ed_votes
    ,sum(healthcare_votes) as health_votes
    ,sum(military_votes) as military_votes
    ,sum(social_votes) as social_votes
    ,sum(sports_votes) as sports_votes
    ,sum(case when category = 'bathroom' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_bath_votes
    ,sum(case when category = 'bathroom' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_bath_votes
    ,sum(case when category = 'education' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_ed_votes
    ,sum(case when category = 'education' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_ed_votes
    ,sum(case when category = 'healthcare' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_health_votes
    ,sum(case when category = 'healthcare' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_health_votes
    ,sum(case when category = 'military' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_military_votes
    ,sum(case when category = 'military' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_military_votes
    ,sum(case when category = 'social' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_social_votes
    ,sum(case when category = 'social' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_social_votes
    ,sum(case when category = 'sports' then pro_trans_votes_for + pro_trans_votes_against else 0 end) as pro_trans_sports_votes
    ,sum(case when category = 'sports' then anti_trans_votes_for + anti_trans_votes_against else 0 end) as anti_trans_sports_votes
  from votes_rollup
  group by people_id
),
averages as (
  select
    people_id
    ,total_votes
    ,pro_trans_votes
    ,anti_trans_votes
    ,case when total_votes=0 then NULL else ((pro_trans_votes/total_votes)*100) end as pro_trans_avg
    ,case when total_votes=0 then NULL else ((anti_trans_votes/total_votes)*100) end as anti_trans_avg
    ,case when bath_votes=0 then NULL else ((pro_trans_bath_votes/bath_votes)*100) end as pro_trans_bath_avg
    ,case when ed_votes=0 then NULL else ((pro_trans_ed_votes/ed_votes)*100) end as pro_trans_ed_avg
    ,case when health_votes=0 then NULL else ((pro_trans_health_votes/health_votes)*100) end as pro_trans_health_avg
    ,case when military_votes=0 then NULL else ((pro_trans_military_votes/military_votes)*100) end as pro_trans_military_avg
    ,case when social_votes=0 then NULL else ((pro_trans_social_votes/social_votes)*100) end as pro_trans_social_avg
    ,case when sports_votes=0 then NULL else ((pro_trans_sports_votes/sports_votes)*100) end as pro_trans_sports_avg
  from category_rollup
)
select 
  people.people_id
  ,people.name
  ,people.party
  ,state
  ,people.role
  ,people.district
  ,total_votes --for double checking math
  ,pro_trans_votes --for double checking math
  ,anti_trans_votes --for double checking math
  ,pro_trans_avg as overall_avg --for double checking math
  ,case
    when pro_trans_avg IS NULL then "no data"
    when pro_trans_avg >=90 then "A"
    when pro_trans_avg >=80 then "B"
    when pro_trans_avg >=70 then "C"
    when pro_trans_avg >=60 then "D"
    else "F"
    end as overall_grade
  ,case 
    when pro_trans_bath_avg IS NULL then "no data" 
    when pro_trans_bath_avg >= 90 then "A"
    when pro_trans_bath_avg >=80 then "B"
    when pro_trans_bath_avg >=70 then "C"
    when pro_trans_bath_avg >=60 then "D"
    else "F"
    end as bathroom_grade
  ,case
    when pro_trans_ed_avg IS NULL then "no data" 
    when pro_trans_ed_avg >= 90 then "A"
    when pro_trans_ed_avg >=80 then "B"
    when pro_trans_ed_avg >=70 then "C"
    when pro_trans_ed_avg >=60 then "D"
    else "F"
    end as education_grade
  ,case
    when pro_trans_health_avg IS NULL then "no data" 
    when pro_trans_health_avg >= 90 then "A"
    when pro_trans_health_avg >=80 then "B"
    when pro_trans_health_avg >=70 then "C"
    when pro_trans_health_avg >=60 then "D"
    else "F"
    end as health_grade
  ,case
    when pro_trans_military_avg IS NULL then "no data" 
    when pro_trans_military_avg >= 90 then "A"
    when pro_trans_military_avg >=80 then "B"
    when pro_trans_military_avg >=70 then "C"
    when pro_trans_military_avg >=60 then "D"
    else "F"
    end as military_grade
  ,case
    when pro_trans_social_avg IS NULL then "no data" 
    when pro_trans_social_avg >= 90 then "A"
    when pro_trans_social_avg >=80 then "B"
    when pro_trans_social_avg >=70 then "C"
    when pro_trans_social_avg >=60 then "D"
    else "F"
    end as social_grade
  ,case
    when pro_trans_sports_avg IS NULL then "no data" 
    when pro_trans_sports_avg >= 90 then "A"
    when pro_trans_sports_avg >=80 then "B"
    when pro_trans_sports_avg >=70 then "C"
    when pro_trans_sports_avg >=60 then "D"
    else "F"
    end as sports_grade
from averages
left join `dxplegislativescorecard-416017.Il_OH_2023_2024.people` as people using (people_id)