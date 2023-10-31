-- 1. For each library member his card number, first, middle and last name along with the number of book copies he ever borrowed. There may be members who didn't ever borrow any book copy.
-- ------------------------------
select m.card_no, m.first_name, m.middle_name, m.last_name, COUNT(distinct b.barcode) AS num_borrowed
from member m
left join BORROW b on m.card_no = b.card_no
group by m.card_no, m.first_name, m.middle_name, m.last_name;
-- ________________________________
-- 2. Members (their card numbers, first, middle and last names) who held a book copy the longest. 
-- There can be one such member or more than one. 
-- Don't take into accout a case that someone borrowed the same book copy again.
-- Don't take into account members who borrowed a book copy and didn't return it yet.
-- --------------------------------
select M.card_no, M.first_name, M.middle_name, M.last_name
from member M
join BORROW B on M.card_no = B.card_no
join (
    select barcode, MAX(DATEDIFF(date_returned, date_borrowed)) AS duration
    from BORROW
    where date_returned is not null
    group by barcode
) L on B.barcode = L.barcode AND DATEDIFF(B.date_returned, B.date_borrowed) = L.duration
join COPY C on B.barcode = C.barcode
join BOOK B2 on C.ISBN = B2.ISBN;

-- ________________________________
-- 3. For each book (ISBN and title) the number of copies the library owns.
-- --------------------------------
select b.ISBN, b.title, COUNT(c.barcode) AS num_copies
from BOOK b
left join COPY c on b.ISBN = c.ISBN
group by b.ISBN, b.title;
-- ________________________________
-- 4. Books (ISBNs and titles), if any, having exactly 3 authors.
-- --------------------------------
select b.ISBN, b.title
from BOOK b
inner join BOOK_AUTHOR ba ON b.ISBN = ba.ISBN
group by b.ISBN, b.title
having COUNT(distinct ba.author_id) = 3;
-- ________________________________
-- 5. For each author (ID, first, middle and last name) the number of books he wrote.
-- --------------------------------
select a.author_id, a.first_name, a.middle_name, a.last_name, COUNT(ba.ISBN) AS num_books
from AUTHOR a
left join BOOK_AUTHOR ba ON a.author_id = ba.author_id
group by a.author_id, a.first_name, a.middle_name, a.last_name;
-- ________________________________
-- 6. Card number, first, middle and last name of members, if any, who borrowed some book by Chartrand(s). 
-- Remove duplicates from the result.
-- --------------------------------
select distinct m.card_no, m.first_name, m.middle_name, m.last_name
from member m
inner join BORROW b on m.card_no = b.card_no
inner join COPY c on b.barcode = c.barcode
inner join BOOK_AUTHOR ba on c.ISBN = ba.ISBN
inner join AUTHOR a on ba.author_id = a.author_id
where LOWER(a.last_name) like '%chartrand%'
-- ________________________________
-- 7. Most popular author(s) (their IDs and first, middle and last names) in the library.
-- --------------------------------
select A.author_id, A.first_name, A.middle_name, A.last_name, COUNT(*) AS borrow_count
from AUTHOR A
join BOOK_AUTHOR BA on A.author_id = BA.author_id
join BOOK B on BA.ISBN = B.ISBN
join COPY C on B.ISBN = C.ISBN
join BORROW BO on C.barcode = BO.barcode
group by A.author_id
order by borrow_count DESC;
-- ________________________________
-- 8. Card numbers, first, middle, last names and addresses of members whose libray card will expire within the next month.
-- --------------------------------
select card_no, first_name, middle_name, last_name, street, city, state, apt_no, zip_code
from member
where card_exp_date between CURDATE() and DATE_ADD(CURDATE(), INTERVAL 1 MONTH);
-- ________________________________
-- 9. Card numbers, first, middle and last names of members along with the amount of money they owe to the library. 
-- Assume that if a book copy is returned one day after the due date, a member ows 0.25 cents to the library.
-- --------------------------------
select M.card_no, M.first_name, M.middle_name, M.last_name, 
SUM(case
    when B.date_returned <= DATE_ADD(B.date_borrowed, interval 1 day) or B.paid = true then 0
    else TIMESTAMPDIFF (day, DATE_ADD(B.date_borrowed, interval 1 day), B.date_returned) * 0.25
end) as amount_owed
from member M
join BORROW B on M.card_no = B.card_no
join COPY C on B.barcode = C.barcode
group by M.card_no, M.first_name, M.middle_name, M.last_name;

-- ________________________________
-- 10. The amount of money the library earned (received money for) from late returns.
-- --------------------------------
select SUM(DATEDIFF(date_returned, date_borrowed) * 0.5) AS late_fees_earned
from BORROW
where date_returned is not null and paid = 1;
-- ________________________________
-- 11. Members (their card numbers, first, middle and last names) who borrowed more non-fiction books than fiction books.
-- --------------------------------
select member.card_no, member.first_name, member.middle_name, member.last_name
from member
join BORROW on member.card_no = BORROW.card_no
join COPY on BORROW.barcode = COPY.barcode
join BOOK on COPY.ISBN = BOOK.ISBN
join GENRE on BOOK.genre_id = GENRE.genre_id
group by member.card_no 
having SUM(case when GENRE.type = 0 then 1 else 0 end) < SUM(case when GENRE.type = 1 then 1 else 0 end)
-- ________________________________
-- 12. Name of the most popular publisher(s).
-- --------------------------------
select BOOK.publisher, COUNT(*) as book_count
from BOOK
group by BOOK.publisher
order by book_count desc
limit 1;
-- ________________________________
-- 13. Members (card numbers, first, middle and last names) who never borrowed any book copy and whose card expired.
-- --------------------------------
select member.card_no, member.first_name, member.middle_name, member.last_name
from member
left join BORROW on member.card_no = BORROW.card_no
where BORROW.card_no is null and member.card_exp_date < CURDATE();
-- ________________________________
-- 14. The most popular genre(s).
-- --------------------------------
select GENRE.name, COUNT(*) as borrow_count
from BORROW
join COPY on BORROW.barcode = COPY.barcode
join BOOK on COPY.ISBN = BOOK.ISBN
join GENRE on BOOK.genre_id = GENRE.genre_id
group by GENRE.name
order by borrow_count desc
limit 1;
-- ________________________________
-- 15. For each state, in which some member lives, the most pupular last name(s). 
-- --------------------------------
select m.state, m.last_name, COUNT(*) as occurrences
from member as m
join BORROW as b on m.card_no = b.card_no
join COPY as c on b.barcode = c.barcode
join BOOK as bk on c.ISBN = bk.ISBN
join BOOK_AUTHOR as ba on bk.ISBN = ba.ISBN
join AUTHOR as a on ba.author_id = a.author_id
join GENRE as g on bk.genre_id = g.genre_id
group by m.state, m.last_name
having COUNT(case when g.type = 0 then 1 else null end) < COUNT(case when g.type = 1 then 1 else null end)
order by m.state, occurrences desc;
-- ________________________________
-- 16. Books (ISBNs and titles) that don't have any authors. 
-- --------------------------------
select BOOK.ISBN, title
from BOOK
left join BOOK_AUTHOR on BOOK.ISBN = BOOK_AUTHOR.ISBN
where BOOK_AUTHOR.ISBN is null;
-- ________________________________
-- 17. Members (card numbers) who borrowed the same book more than once (not necessarily the same copy of a book).
-- --------------------------------
select DISTINCT B1.card_no
from BORROW B1
join BORROW B2 on B1.barcode = B2.barcode and B1.card_no = B2.card_no and B1.date_borrowed < B2.date_borrowed
-- ________________________________
-- 18. Number of members from Cookeville, TN and from Algood, TN.
-- --------------------------------
select city, COUNT(*) as num_members
from member
where city in ('Cookeville', 'Algood')
group by city;
-- ________________________________
-- 19. Card numbers and emails of members who should return a book copy tomorrow. If these members didn't renew their loan twice, then they still have a chance to renew their loan. If they won't renew or return a book tomorrow, then they will be charged for the following day(s).
-- --------------------------------
select member.card_no, member.email_address
from member
join BORROW on member.card_no = BORROW.card_no
join COPY on BORROW.barcode = COPY.barcode
where BORROW.date_borrowed = date(NOW() - interval 1 day)
and BORROW.date_returned is null
and BORROW.renewals_no < 2;
-- ________________________________
-- 20. Condition of a book copy that was borrowed the most often, not necessarily held the longest.
-- --------------------------------
select COPY.ISBN
from COPY
join (
    select BORROW.ISBN, BORROW.COPY_barcode, COUNT(*) AS num_borrowed
    from BORROW
    group by BORROW.ISBN, borrow.COPY_barcode
    order by num_borrowed DESC
    limit 1
) as most_borrowed ON COPY.ISBN = most_borrowed.ISBN AND COPY.COPY_barcode = most_borrowed.COPY_barcode;
-- ________________________________