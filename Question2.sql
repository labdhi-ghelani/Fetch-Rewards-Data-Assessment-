--2A. What are the top 5 brands by receipts scanned for most recent month?
with brands_cte as (
select distinct name, brandCode from brands
),
items as (
select receipts_id, brandcode from rewards_receipts_item
),
receipts_cte as (
select _id as receiptid, strftime('%Y-%m', dateScanned) as date from receipts
)

select 
r.date, 
b.name, 
count(r.receiptid) as count_receiptid 
from receipts_cte as r
inner join items as i on i.receipts_id=r.receiptid
inner join brands as b on i.brandCode=b.brandcode
group by 1,2
having r.date = '2021-01'
order by 3 desc 
limit 5;


--2B. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
select 
case when rewardsReceiptStatus='FINISHED' then 'ACCEPTED' else 'REJECTED' end
from receipts
where rewardsReceiptStatus in ('FINISHED','REJECTED')
group by rewardsReceiptStatus
order by avg(totalspent) desc
limit 1;

--2C. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
select case when rewardsReceiptStatus='FINISHED' then 'ACCEPTED' else 'REJECTED' end
from receipts
where rewardsReceiptStatus in ('FINISHED','REJECTED')
group by rewardsReceiptStatus
order by sum(purchasedItemCount) desc
limit 1;


--2D. Which brand has the most spend among users who were created within the past 6 months?
with users_cte as (
select distinct _id as userid from users
where createddate >= (select date(max(createddate), '-6 month') from users)
),
receipts_cte as (
select userid, totalspent, _id as r_id from receipts
),
items_cte as (
select brandcode, receipts_id from rewards_receipts_item
)
select i.brandcode, sum(r.totalspent)
from items_cte as i
join receipts_cte r on i.receipts_id=r.r_id
where r.userid in (select userid from users_cte)
and i.brandcode is not null
group by 1 
order by 2 desc
limit 1;
