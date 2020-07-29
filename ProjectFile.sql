-- views --

create view customer_sim_details
as

select c.Customer_name, s.Mobile_No , s.MSISDN_No, m.Plan_Name, a.Area_Code
from customer c inner join sim s
on c.idCustomer = s.fk_customer
inner join mobile_service m
on s.idSim = m.Sim_ID
inner join area a
on m.idMobile_Service= a.Mobile_Service_ID;


select * from customer_sim_details;









create view customer_bill_payment
as

select c.idCustomer, c.Customer_name, bd.idBill_Details,
bd.Bill_Cycle,  bd.Start_Date, bd.End_Date, 
bd.Monthly_Rental, bd.Amount, p.Payment_Type
from customer c inner join bill_details bd
on c.idCustomer = bd.Customer_ID
inner join payment p
on bd.idBill_Details = p.Bill_No;



select * from customer_bill_payment;





create view customer_plan_details1
as 

select c.Customer_name, s.Mobile_No, mobile_service.Cal_Rate, 
mobile_service.SMS_Rate,mobile_service.Data_Charges,
service_type.Service_Type, plan_details.Plan_Name
from customer c inner join sim s
on c.idCustomer = s.fk_customer
inner join mobile_service
on s.idSim = mobile_service.Sim_ID
inner join service_type
on mobile_service.idMobile_Service = service_type.idService_Type
inner join plan_details
on service_type.idService_Type = plan_details.Service_Id;



select * from customer_plan_details1;





-- stored procedure --

delimiter &&
create procedure sp_customer_info (in type varchar(45))
begin

select customer.idCustomer, customer.Customer_name,sim.Mobile_No,
 mobile_service.Plan_Name, service_type.Service_Type from customer inner join sim
 on customer.idCustomer = sim.fk_customer 
 inner join mobile_service 
 on sim.idSim = mobile_service.Sim_ID
 inner join service_type
 on mobile_service.fk_service_id = service_type.idService_Type where service_type=type;

end;
&&




call sp_customer_info('postpaid');





delimiter &&
create procedure sp_customer_information1(in MSISDN_No INT)
begin
select customer.idCustomer, customer.Customer_name,sim.Mobile_No,
sim.MSISDN_No from customer inner join sim
 on customer.idCustomer = sim.fk_customer where sim.MSISDN_No = MSISDN_No; 
 
 end;
&&


call sp_customer_information1(99887766);


-- Data Analysis --

-- call time calculation--

select customer.idCustomer, customer.Customer_name, call_transactions.Date, 
timediff(call_transactions.End_Time, call_transactions.Start_Time) as Duration
from customer inner join call_transactions
on customer.idCustomer = call_transactions.Cust_ID;



-- List of customers having family plan --

select customer.idCustomer, customer.Customer_name, sim.Mobile_No, 
mobile_service.Plan_Name from customer inner join sim
on customer.idCustomer = sim.fk_customer
inner join mobile_service
on sim.idSim = mobile_service.sim_ID where Plan_Name= 'family';




-- List of customers in same area --

select customer.idCustomer, customer.Customer_name, sim.Mobile_No, mobile_service.Plan_Name,
area.Area_Code from customer inner join sim
on customer.idCustomer = sim.fk_customer
inner join mobile_service
on sim.idSim = mobile_service.sim_ID
inner join area
on mobile_service.idMobile_Service = area.Mobile_Service_ID 
where Area_Code = '02115';







-- UDF --
DELIMITER $$
 
CREATE FUNCTION credit_limits(credit_limit double) RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE status varchar(10);
 
    IF credit_limit > 50 THEN
 SET status = 'Deactivate';
    ELSEIF (credit_limit <= 50) THEN
        SET status = 'Activate';
    
    END IF;
 
 RETURN (status);
END $$
DELIMITER ;



SELECT bill_details.Customer_ID,credit_limits(credit_limit) 
from bill_details ORDER BY credit_limit;








