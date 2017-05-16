import unittest
from example import example_service
import json


class TestExampleService(unittest.TestCase):
    def setUp(self):
        self.app = example_service.app.test_client()
        self.context = example_service.app.test_request_context()
        self.context.push()

    def tearDown(self):
        self.context.pop()

    def test_hello_world(self):
        self.assertEqual(self.app.get('/').data, b'Hello, world!')

    def test_submit_application(self):
        user_app = [{'id': '68407301', 'member_id': '73297138', 'loan_amnt': '27500', 'funded_amnt': '27500', 'funded_amnt_inv': '27500', 'term': ' 60 months', 'int_rate': ' 14.85%', 'installment': '652.06', 'grade': 'C', 'sub_grade': 'C5', 'emp_title': 'Manager', 'emp_length': '10+ years', 'home_ownership': 'MORTGAGE', 'annual_inc': '195000', 'verification_status': 'Not Verified', 'issue_d': 'Dec-2015', 'loan_status': 'Fully Paid', 'pymnt_plan': 'n', 'url': 'https://lendingclub.com/browse/loanDetail.action?loan_id=68407301', 'desc': '', 'purpose': 'other', 'title': 'Other', 'zip_code': '710xx', 'addr_state': 'LA', 'dti': '6.79', 'delinq_2yrs': '0', 'earliest_cr_line': 'Jul-2001', 'inq_last_6mths': '0', 'mths_since_last_delinq': '', 'mths_since_last_record': '', 'open_acc': '14', 'pub_rec': '0', 'revol_bal': '34974', 'revol_util': '50.9%', 'total_acc': '19', 'initial_list_status': 'w', 'out_prncp': '0.00', 'out_prncp_inv': '0.00', 'total_pymnt': '29753.17', 'total_pymnt_inv': '29753.17', 'total_rec_prncp': '27500.00', 'total_rec_int': '2253.17', 'total_rec_late_fee': '0.0', 'recoveries': '0.0', 'collection_recovery_fee': '0.0', 'last_pymnt_d': 'Aug-2016', 'last_pymnt_amnt': '25897.53', 'next_pymnt_d': '', 'last_credit_pull_d': 'Jul-2016', 'collections_12_mths_ex_med': '0', 'mths_since_last_major_derog': '', 'policy_code': '1', 'application_type': 'INDIVIDUAL', 'annual_inc_joint': '', 'dti_joint': '', 'verification_status_joint': '', 'acc_now_delinq': '0', 'tot_coll_amt': '0', 'tot_cur_bal': '267500', 'open_acc_6m': '1', 'open_il_6m': '1', 'open_il_12m': '0', 'open_il_24m': '1', 'mths_since_rcnt_il': '21', 'total_bal_il': '10003', 'il_util': '75.8', 'open_rv_12m': '1', 'open_rv_24m': '3', 'max_bal_bc': '12056', 'all_util': '54.9', 'total_rev_hi_lim': '68700', 'inq_fi': '0', 'total_cu_tl': '0', 'inq_last_12m': '0', 'acc_open_past_24mths': '4', 'avg_cur_bal': '19107', 'bc_open_to_buy': '23969', 'bc_util': '56.8', 'chargeoff_within_12_mths': '0', 'delinq_amnt': '0', 'mo_sin_old_il_acct': '21', 'mo_sin_old_rev_tl_op': '173', 'mo_sin_rcnt_rev_tl_op': '3', 'mo_sin_rcnt_tl': '3', 'mort_acc': '1', 'mths_since_recent_bc': '3', 'mths_since_recent_bc_dlq': '', 'mths_since_recent_inq': '', 'mths_since_recent_revol_delinq': '', 'num_accts_ever_120_pd': '0', 'num_actv_bc_tl': '6', 'num_actv_rev_tl': '10', 'num_bc_sats': '7', 'num_bc_tl': '9', 'num_il_tl': '1', 'num_op_rev_tl': '12', 'num_rev_accts': '17', 'num_rev_tl_bal_gt_0': '10', 'num_sats': '14', 'num_tl_120dpd_2m': '0', 'num_tl_30dpd': '0', 'num_tl_90g_dpd_24m': '0', 'num_tl_op_past_12m': '1', 'pct_tl_nvr_dlq': '100', 'percent_bc_gt_75': '57.1', 'pub_rec_bankruptcies': '0', 'tax_liens': '0', 'tot_hi_cred_lim': '325100', 'total_bal_ex_mort': '44977', 'total_bc_limit': '55500', 'total_il_high_credit_limit': '13200'}]
        response = self.app.post('/apps', data=json.dumps(user_app))
        self.assertEqual(response.status_code, 200)

    def test_receive_events(self):
        response = self.app.get('/events')
        self.assertEqual(self.app.get('/events').data, b'[]')
