// Composes gross salary -> statutory deductions -> taxable income ->
// annual tax (via tax_slabs.dart) -> monthly TDS -> net pay.
//
// Frontend-only: this replaces hardcoded payslip numbers with a real
// calculation from a few inputs (basic salary, allowances, elected
// deduction contributions) — no backend needed, all pure Dart.

import 'tax_slabs.dart';

class PayrollInput {
  final double basicSalary; // monthly
  final double allowances; // monthly, sum of DA/transport/etc.
  final FilingStatus filingStatus;
  final int fiscalStartYear; // e.g. 2082 for FY 2082/83

  /// Employee's SSF contribution — 11% of basic is standard practice;
  /// set to 0 if this employee is on PF instead of SSF.
  final double socialSecurityFundRate;

  /// Provident Fund employee contribution rate (typically 10%), used
  /// instead of SSF at companies not yet migrated to SSF.
  final double providentFundRate;

  /// Voluntary deductions that reduce taxable income — CIT contribution,
  /// life/health insurance premium. IRD caps how much of these are
  /// deductible in reality; see the NOTE on computePayroll below.
  final double citContribution; // monthly
  final double insurancePremium; // monthly

  const PayrollInput({
    required this.basicSalary,
    required this.allowances,
    required this.filingStatus,
    required this.fiscalStartYear,
    this.socialSecurityFundRate = 0.11,
    this.providentFundRate = 0.0,
    this.citContribution = 0.0,
    this.insurancePremium = 0.0,
  });

  double get grossMonthly => basicSalary + allowances;
  double get grossAnnual => grossMonthly * 12;
}

class PayrollResult {
  final double grossMonthly;
  final double socialSecurityFundDeduction;
  final double providentFundDeduction;
  final double citDeduction;
  final double insuranceDeduction;
  final double monthlyTax; // TDS
  final double netMonthly;

  /// What tax was actually computed on, per year, after capped deductions.
  final double taxableAnnualIncome;

  /// True when contributions exceed what's tax-deductible — anything past
  /// the cap still leaves your pay, but saves no further tax. The Tax
  /// Planner uses these to say so instead of overstating savings.
  final bool retirementCapReached;
  final bool insuranceCapReached;

  const PayrollResult({
    required this.grossMonthly,
    required this.socialSecurityFundDeduction,
    required this.providentFundDeduction,
    required this.citDeduction,
    required this.insuranceDeduction,
    required this.monthlyTax,
    required this.netMonthly,
    required this.taxableAnnualIncome,
    required this.retirementCapReached,
    required this.insuranceCapReached,
  });

  double get totalDeductions =>
      socialSecurityFundDeduction +
      providentFundDeduction +
      citDeduction +
      insuranceDeduction +
      monthlyTax;
}

/// NOTE(finance-review): placeholder deduction limits, modeled on Nepal's
/// Income Tax Act — retirement contributions (PF + SSF + CIT) deductible
/// up to the LOWER of one third of assessable income or Rs 500,000 a year;
/// life insurance premium deductible up to Rs 40,000 a year. Verify both
/// against the current Finance Act before trusting any tax figure.
const retirementDeductionCapAnnual = 500000.0;
const retirementDeductionIncomeShare = 1 / 3;
const insuranceDeductionCapAnnual = 40000.0;

PayrollResult computePayroll(PayrollInput input) {
  final ssf = input.grossMonthly * input.socialSecurityFundRate;
  final pf = input.basicSalary * input.providentFundRate;

  final grossAnnual = input.grossMonthly * 12;

  // Deductible amounts are capped; the cash actually deducted from pay is
  // not. Mixing those two up is how a tax planner overpromises savings.
  final retirementAnnual = (ssf + pf + input.citContribution) * 12;
  final retirementCap = [
    grossAnnual * retirementDeductionIncomeShare,
    retirementDeductionCapAnnual,
  ].reduce((a, b) => a < b ? a : b);
  final retirementAllowed = retirementAnnual < retirementCap
      ? retirementAnnual
      : retirementCap;

  final insuranceAnnual = input.insurancePremium * 12;
  final insuranceAllowed = insuranceAnnual < insuranceDeductionCapAnnual
      ? insuranceAnnual
      : insuranceDeductionCapAnnual;

  final rawTaxable = grossAnnual - retirementAllowed - insuranceAllowed;
  final taxableAnnualIncome = rawTaxable < 0 ? 0.0 : rawTaxable;

  final slabs = slabsFor(input.fiscalStartYear, input.filingStatus);
  final monthlyTax = annualTax(taxableAnnualIncome, slabs) / 12;

  final cashDeductionsBeforeTax =
      ssf + pf + input.citContribution + input.insurancePremium;
  final netMonthly = input.grossMonthly - cashDeductionsBeforeTax - monthlyTax;

  return PayrollResult(
    grossMonthly: input.grossMonthly,
    socialSecurityFundDeduction: ssf,
    providentFundDeduction: pf,
    citDeduction: input.citContribution,
    insuranceDeduction: input.insurancePremium,
    monthlyTax: monthlyTax,
    netMonthly: netMonthly,
    taxableAnnualIncome: taxableAnnualIncome,
    retirementCapReached: retirementAnnual > retirementCap,
    insuranceCapReached: insuranceAnnual > insuranceDeductionCapAnnual,
  );
}
