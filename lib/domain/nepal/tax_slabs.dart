// Nepal individual income tax slabs — progressive, and DIFFERENT for
// single vs married filers. Numbers below are illustrative placeholders
// modeled on IRD Nepal's typical slab structure — NOT verified against
// the current fiscal year's official notice. Update `slabsByFyAndStatus`
// only; nothing else in the payroll code needs to change when IRD
// revises the slabs.
//

// the fiscal year this app is actually used in, before trusting any
// number this produces.

enum FilingStatus { single, married }

/// One tax bracket: income up to [upTo] (cumulative, not this-band-only)
/// is taxed at [rate]. The last slab in a list should use
/// `double.infinity` for [upTo].
class TaxSlab {
  final double upTo;
  final double rate; // e.g. 0.01 for 1%, 0.20 for 20%

  const TaxSlab(this.upTo, this.rate);
}

/// Slabs keyed by "startYear-status", e.g. "2082-single".
/// Values are PLACEHOLDERS — see file-level 
const Map<String, List<TaxSlab>> slabsByFyAndStatus = {
  '2082-single': [
    TaxSlab(500000, 0.01), // Social Security Tax band
    TaxSlab(700000, 0.10),
    TaxSlab(1000000, 0.20),
    TaxSlab(2000000, 0.30),
    TaxSlab(double.infinity, 0.36),
  ],
  '2082-married': [
    TaxSlab(600000, 0.01),
    TaxSlab(800000, 0.10),
    TaxSlab(1100000, 0.20),
    TaxSlab(2000000, 0.30),
    TaxSlab(double.infinity, 0.36),
  ],
};

/// Looks up slabs for a fiscal year + filing status, falling back to
/// the latest known year if that exact year isn't in the table yet.
List<TaxSlab> slabsFor(int fiscalStartYear, FilingStatus status) {
  final key = '$fiscalStartYear-${status.name}';
  return slabsByFyAndStatus[key] ?? slabsByFyAndStatus['2082-${status.name}']!;
}

/// Applies progressive slabs to [taxableAnnualIncome] and returns the
/// total annual tax. Each slab's rate applies only to the portion of
/// income that falls within that band, not the whole income.
double annualTax(double taxableAnnualIncome, List<TaxSlab> slabs) {
  var remaining = taxableAnnualIncome;
  var lowerBound = 0.0;
  var tax = 0.0;

  for (final slab in slabs) {
    if (remaining <= 0) break;
    final bandSize = slab.upTo - lowerBound;
    final amountInBand = remaining < bandSize ? remaining : bandSize;
    tax += amountInBand * slab.rate;
    remaining -= amountInBand;
    lowerBound = slab.upTo;
  }

  return tax;
}
