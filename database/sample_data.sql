USE payroll_hr_demo;

-- Ten demo departments. INSERT IGNORE keeps this script safe to rerun.
INSERT IGNORE INTO departments(name,description) VALUES
('Human Resources','People operations'),
('Engineering','Product development'),
('Finance','Finance and payroll'),
('Sales','Customer sales and partnerships'),
('Marketing','Brand and communications'),
('Operations','Business operations'),
('IT Support','Technology support'),
('Customer Service','Customer care'),
('Legal','Legal and compliance'),
('Procurement','Purchasing and vendor management');

-- Fictional employees, one per demo department.
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-001','Asha','Rao','asha.rao@example.test','9000000001',id,'HR Coordinator','2024-01-15','ACTIVE','Demo address' FROM departments WHERE name='Human Resources';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-002','Ravi','Kumar','ravi.kumar@example.test','9000000002',id,'Software Associate','2023-08-01','ACTIVE','Demo address' FROM departments WHERE name='Engineering';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-003','Maya','Shah','maya.shah@example.test','9000000003',id,'Accountant','2022-03-14','ACTIVE','Demo address' FROM departments WHERE name='Finance';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-004','Arjun','Mehta','arjun.mehta@example.test','9000000004',id,'Sales Executive','2023-02-20','ACTIVE','Demo address' FROM departments WHERE name='Sales';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-005','Nisha','Iyer','nisha.iyer@example.test','9000000005',id,'Marketing Specialist','2024-05-06','ACTIVE','Demo address' FROM departments WHERE name='Marketing';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-006','Kabir','Singh','kabir.singh@example.test','9000000006',id,'Operations Analyst','2021-11-08','ACTIVE','Demo address' FROM departments WHERE name='Operations';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-007','Tara','Nair','tara.nair@example.test','9000000007',id,'IT Support Engineer','2022-07-18','ACTIVE','Demo address' FROM departments WHERE name='IT Support';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-008','Dev','Patel','dev.patel@example.test','9000000008',id,'Customer Care Associate','2024-02-12','ACTIVE','Demo address' FROM departments WHERE name='Customer Service';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-009','Leela','Reddy','leela.reddy@example.test','9000000009',id,'Compliance Officer','2020-09-21','ACTIVE','Demo address' FROM departments WHERE name='Legal';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-010','Omar','Khan','omar.khan@example.test','9000000010',id,'Procurement Associate','2023-06-26','ACTIVE','Demo address' FROM departments WHERE name='Procurement';

-- Effective salary examples for each employee.
INSERT INTO salary_structures(employee_id,basic,hra,other_allowances,bonus,deductions,effective_start)
SELECT e.id,
       CASE e.employee_code WHEN 'DEMO-001' THEN 30000 WHEN 'DEMO-002' THEN 42000 WHEN 'DEMO-003' THEN 38000 WHEN 'DEMO-004' THEN 32000 WHEN 'DEMO-005' THEN 35000 WHEN 'DEMO-006' THEN 40000 WHEN 'DEMO-007' THEN 36000 WHEN 'DEMO-008' THEN 28000 WHEN 'DEMO-009' THEN 50000 ELSE 31000 END,
       CASE e.employee_code WHEN 'DEMO-001' THEN 12000 WHEN 'DEMO-002' THEN 16800 WHEN 'DEMO-003' THEN 15200 WHEN 'DEMO-004' THEN 12800 WHEN 'DEMO-005' THEN 14000 WHEN 'DEMO-006' THEN 16000 WHEN 'DEMO-007' THEN 14400 WHEN 'DEMO-008' THEN 11200 WHEN 'DEMO-009' THEN 20000 ELSE 12400 END,
       2500, CASE WHEN e.employee_code='DEMO-004' THEN 1500 ELSE 0 END,
       CASE e.employee_code WHEN 'DEMO-001' THEN 1000 WHEN 'DEMO-002' THEN 1500 WHEN 'DEMO-003' THEN 1200 ELSE 900 END,
       '2024-01-01'
FROM employees e
WHERE e.employee_code BETWEEN 'DEMO-001' AND 'DEMO-010'
  AND NOT EXISTS (SELECT 1 FROM salary_structures s WHERE s.employee_id=e.id AND s.effective_start='2024-01-01');

-- Attendance for today and yesterday; unique keys make reruns harmless.
INSERT IGNORE INTO attendance(employee_id,attendance_date,status)
SELECT e.id,CURRENT_DATE,
       CASE e.employee_code WHEN 'DEMO-003' THEN 'HALF_DAY' WHEN 'DEMO-008' THEN 'ABSENT' ELSE 'PRESENT' END
FROM employees e WHERE e.employee_code BETWEEN 'DEMO-001' AND 'DEMO-010';
INSERT IGNORE INTO attendance(employee_id,attendance_date,status)
SELECT e.id,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY),
       CASE e.employee_code WHEN 'DEMO-006' THEN 'LEAVE' ELSE 'PRESENT' END
FROM employees e WHERE e.employee_code BETWEEN 'DEMO-001' AND 'DEMO-010';

-- Example pending and approved leave requests.
INSERT INTO leave_requests(employee_id,start_date,end_date,reason,status)
SELECT e.id,'2026-11-05','2026-11-06','Family event - demo request','PENDING'
FROM employees e
WHERE e.employee_code='DEMO-003'
  AND NOT EXISTS (SELECT 1 FROM leave_requests l WHERE l.employee_id=e.id AND l.reason='Family event - demo request');
INSERT INTO leave_requests(employee_id,start_date,end_date,reason,status,reviewed_at)
SELECT e.id,'2026-09-12','2026-09-13','Personal leave - approved demo','APPROVED','2026-09-01 10:00:00'
FROM employees e
WHERE e.employee_code='DEMO-005'
  AND NOT EXISTS (SELECT 1 FROM leave_requests l WHERE l.employee_id=e.id AND l.reason='Personal leave - approved demo');

-- Current-month payroll snapshots power the payroll, payslip, and report screens.
INSERT INTO payroll(employee_id,payroll_month,basic,hra,other_allowances,bonus,deductions,gross,net,status)
SELECT e.id,DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'),s.basic,s.hra,s.other_allowances,s.bonus,s.deductions,
       s.basic+s.hra+s.other_allowances+s.bonus,
       s.basic+s.hra+s.other_allowances+s.bonus-s.deductions,
       CASE WHEN e.employee_code IN ('DEMO-001','DEMO-002') THEN 'PAID' ELSE 'GENERATED' END
FROM employees e
JOIN salary_structures s ON s.employee_id=e.id AND s.effective_start<='2024-01-01'
WHERE e.employee_code BETWEEN 'DEMO-001' AND 'DEMO-010'
  AND NOT EXISTS (SELECT 1 FROM payroll p WHERE p.employee_id=e.id AND p.payroll_month=DATE_FORMAT(CURRENT_DATE,'%Y-%m-01'));
