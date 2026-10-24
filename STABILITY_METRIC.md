# Stability Metric for Polymarket Odds

## Goal
Quantify how smoothly the market probability drifts from its current value toward the assumed eventual outcome of 100 % at the market’s expiration date.

## Assumptions
* The “true” probability of the event will converge to 100 % by the market’s `endDate` (expiry).
* We have a time‑series of observed probabilities \(p(t_i)\) (e.g., from the Polymarket Data‑API or from periodic snapshots).
* Let \(t_0\) be the timestamp of the first observation and \(T\) the market’s expiry (`endDate`).

## Ideal (reference) path
If the odds were to move perfectly linearly toward 100 %, the reference probability at any time \(t\) would be:

\[
p_{\text{ideal}}(t) = p(t_0) + \frac{1 - p(t_0)}{T - t_0}\;(t - t_0)
\]

where \(p(t_0)\) is the observed probability at the start of the observation window.

## Deviation measures
We compare the actual series \(p(t_i)\) to the ideal line.

### 1. Integrated Absolute Deviation (IAD)
\[
\text{IAD} = \frac{1}{T - t_0}\int_{t_0}^{T} \bigl| p(t) - p_{\text{ideal}}(t) \bigr| \, dt
\]
*Units*: probability‑points·time (normalized by interval length → average absolute deviation in probability‑points).  
*Interpretation*: Lower IAD → the odds stay closer to a smooth linear drift.

### 2. Root‑Mean‑Square Deviation (RMSD)
\[
\text{RMSD} = \sqrt{ \frac{1}{T - t_0}\int_{t_0}^{T} \bigl[ p(t) - p_{\text{ideal}}(t) \bigr]^2 \, dt }
\]
*Units*: probability‑points (same as above but penalises larger deviations more strongly).

### 3. Normalized RMSD (NRMSD)
\[
\text{NRMSD} = \frac{\text{RMSD}}{1 - p(t_0)}
\]
*Range*: 0 – 1 (0 = perfect linear drift, 1 = deviation as large as the total possible move).  
*Stability score*: \(S = 1 - \text{NRMSD}\) (higher = more stable).

## Practical computation (discrete data)
Given observations at times \(t_0, t_1, …, t_n\) (with \(t_n \le T\)):

\[
\Delta t_i = t_{i+1} - t_i
\]

\[
\text{IAD} \approx \frac{\sum_{i=0}^{n-1} \bigl| p_i - p_{\text{ideal}}(t_i) \bigr| \, \Delta t_i}{T - t_0}
\]

\[
\text{RMSD} \approx \sqrt{ \frac{\sum_{i=0}^{n-1} \bigl[ p_i - p_{\text{ideal}}(t_i) \bigr]^2 \, \Delta t_i}{T - t_0} }
\]

If the final observation is before expiry, we can optionally extrapolate the last observed probability to \(T\) (assume it stays constant) or treat the missing interval as zero deviation (depending on desired conservatism).

## Usage
* Compute the metric for each market to rank them by “smoothness of odds movement”.
* Combine with other factors (liquidity, volume, etc.) to filter markets that not only meet a probability threshold but also exhibit predictable drift.
* The metric can be stored as a derived column (e.g., `stability_score`) in the `PMKT.POLYMARKET_MARKETS` table if historical odds are persisted.

## References
* Concept adapted from forecasting error measures (MAE, RMSE) applied to probability paths.
* Normalisation enables comparison across markets with different starting probabilities.

