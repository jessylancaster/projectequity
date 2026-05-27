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
  )
,votes_rollup as (
  select
    people_id
    ,bill_id
    ,sum(case when anti_pro = 'pro-trans' then votes_for else 0 end) as pro_trans_votes_for
    ,sum(case when anti_pro = 'anti-trans' then votes_against else 0 end) as pro_trans_votes_against
    ,sum(case when anti_pro = 'anti-trans' then votes_for else 0 end) as anti_trans_votes_for
    ,sum(case when anti_pro = 'pro-trans' then votes_against else 0 end) as anti_trans_votes_against
    ,sum(total_votes) as total_votes
  from vote_counts
  group by people_id, bill_id
)
select
  people_id
  ,name
  ,bills.bill_id
  ,bills.state
  ,bills.anti_pro
  ,bills.category
  ,bills.bill_number
  ,bills.description
  ,bills.status_desc
  ,bills.status_date
  ,pro_trans_votes_for + pro_trans_votes_against as pro_trans_votes
  --,anti_trans_votes_for + anti_trans_votes_against as anti_trans_votes
  ,total_votes
from votes_rollup
left join `dxplegislativescorecard-416017.Il_OH_2023_2024.people` as people using (people_id)
left join `dxplegislativescorecard-416017.Il_OH_2023_2024.bills` AS bills USING (bill_id)
