USE payroll_hr_demo;
INSERT IGNORE INTO departments(name,description) VALUES ('Human Resources','People operations'),('Engineering','Product development'),('Finance','Finance and payroll');
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-001','Asha','Rao','asha.rao@example.test','9000000001',id,'HR Coordinator','2024-01-15','ACTIVE','Demo address' FROM departments WHERE name='Human Resources';
INSERT IGNORE INTO employees(employee_code,first_name,last_name,email,phone,department_id,job_title,joining_date,status,address)
SELECT 'DEMO-002','Ravi','Kumar','ravi.kumar@example.test','9000000002',id,'Software Associate','2023-08-01','ACTIVE','Demo address' FROM departments WHERE name='Engineering';
INSERT INTO salary_structures(employee_id,basic,hra,other_allowances,bonus,deductions,effective_start)
SELECT id,30000,12000,2500,0,1000,'2024-01-01' FROM employees WHERE employee_code='DEMO-001' AND NOT EXISTS(SELECT 1 FROM salary_structures s WHERE s.employee_id=employees.id);
INSERT INTO salary_structures(employee_id,basic,hra,other_allowances,bonus,deductions,effective_start)
SELECT id,42000,16800,3500,0,1500,'2024-01-01' FROM employees WHERE employee_code='DEMO-002' AND NOT EXISTS(SELECT 1 FROM salary_structures s WHERE s.employee_id=employees.id);
