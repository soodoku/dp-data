import hashlib
import warnings
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
s = pd.read_parquet(ROOT / "data/zeguo-2005/survey.parquet")
pre = pd.read_parquet(ROOT / "data/zeguo-2005/source-materials/pre.parquet").set_index(
    "p"
)
post = pd.read_parquet(
    ROOT / "data/zeguo-2005/source-materials/post.parquet"
).set_index("p")
measures = pd.read_parquet(ROOT / "output/respondent/respondent_measures.parquet")
measures = measures[measures.poll_id.eq("zeguo-2005")].copy()
measures["name"] = (
    measures.definition_id.str.split("@").str[0].str.removeprefix("zeguo-2005.")
)
wide = measures.pivot(index="respondent_id", columns="name", values="value_numeric")
ids = s.p.astype(int).astype(str)
wide = wide.loc[ids]
pdata = pd.read_parquet(ROOT / "output/polardata/polardata.parquet")
pdata = pdata[pdata.pollid.eq(52)].set_index("caseid")
selected = s.groupnum.notna() & s.preandpost.notna()
assert (
    selected.sum() == 233
    and s.p.is_unique
    and pre.index.is_unique
    and post.index.is_unique
)
assert set(pdata.index) == set((52000 + s.loc[selected, "p"]).astype(int))
batteries = {
    "industrial_roads": [14, 20, 21],
    "village_roads": [7, 10, 11],
    "main_roads": [15, 16, 17, 18, 19, 22],
    "commercial_roads": [12, 13],
    "wenchang_main_avenue": [6],
    "other_parks": [24, 28, 29],
    "township_image": [25, 31],
    "cultural_heritage": [25, 32],
    "sewage": [30, 33, 34, 35],
}
checks = []
coverage = []
expected = {}


def float32(x):
    return np.asarray(x, dtype=np.float32).astype(float)


def battery(nums, wave, raw_first=False, fallback=True):
    fields = [f"d20{i:02}" + ("p" if wave == 2 else "") for i in nums]
    x = s[fields].to_numpy(float)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", RuntimeWarning)
        if raw_first:
            value = float32(np.nanmean(x, axis=1)) / 10
        else:
            value = float32(np.nanmean(float32(x / 10), axis=1))
    count = np.isfinite(x).sum(axis=1)
    if fallback:
        value[count == 0] = 0.5
    return value, count, fields


def compare(label, observed, value, atol=1e-12):
    observed = np.asarray(observed, float)
    value = np.asarray(value, float)
    bad = ~np.isclose(observed, value, rtol=0, atol=atol, equal_nan=True)
    checks.append(
        {
            "check": label,
            "n": len(value),
            "differences": int(bad.sum()),
            "max_absolute_difference": float(np.nanmax(np.abs(observed - value))),
        }
    )
    assert not bad.any(), (label, np.flatnonzero(bad).tolist())


for index, (name, nums) in enumerate(batteries.items(), 1):
    for wave in (1, 2):
        value, count, fields = battery(
            nums, wave, name in ["other_parks", "township_image"]
        )
        key = f"{name}_t{wave}"
        expected[key] = value
        compare("respondent:" + key, wide[key], value)
        obs = pdata.loc[
            (52000 + s.loc[selected, "p"]).astype(int), f"chi.t{wave}att{index}"
        ]
        compare("selected:" + key, obs, value[selected])
        recorded = measures[measures.name.eq(key)].set_index("respondent_id").loc[ids]
        compare("component_counts:" + key, recorded.n_observed_fields, count)
        coverage.append(
            {
                "index": name,
                "wave": wave,
                "fields": "|".join(fields),
                "source_n": 269,
                "selected_n": 233,
                "n_observed_any": int((count > 0).sum()),
                "n_complete": int((count == len(nums)).sum()),
                "n_all_missing_midpoint": int((count == 0).sum()),
                "selected_all_missing_midpoint": int((count[selected] == 0).sum()),
                "minimum": float(value.min()),
                "maximum": float(value.max()),
                "direction": "higher project importance",
                "denominator": "available component count",
            }
        )
baseline = np.column_stack([expected[f"{n}_t1"] for n in batteries])
knowledge = {}
ledger = pd.read_csv(
    ROOT / "data/zeguo-2005/source-materials/knowledge-reconciliation.csv"
)
for wave, prefix in [(1, "pre"), (2, "post")]:
    fields = [f"{prefix}_d304{i}" for i in range(3, 7)]
    scores = s[fields].eq(3).astype(float).to_numpy()
    if wave == 2:
        for row in ledger.itertuples():
            i = np.flatnonzero(s.p.eq(row.p))[0]
            scores[i, fields.index(row.item)] = row.historical_score
    knowledge[wave] = scores
    compare(f"knowledge_t{wave}", wide[f"knowledge_t{wave}"], scores.mean(axis=1))
compare(
    "knowledge_joint", wide.knowledge_joint, (knowledge[1] * knowledge[2]).mean(axis=1)
)
ext = np.abs(baseline - 0.5).mean(axis=1)
compare("respondent:extremity", wide.attitude_extremity, ext)
compare(
    "selected:extremity",
    pdata.loc[(52000 + s.loc[selected, "p"]).astype(int), "attextreme"],
    ext[selected],
)
group_summary = []
for group in sorted(s.loc[selected, "groupnum"].unique()):
    take = selected & s.groupnum.eq(group)
    x = baseline[take]
    cov = np.cov(x, rowvar=False, ddof=1)
    eigen = np.linalg.eigvalsh(cov)
    assert eigen.min() > 0
    genvar = np.sqrt(np.sqrt(np.linalg.det(cov) ** 2) ** (1 / x.shape[1]))
    avg_sd = np.std(x, axis=0, ddof=1).mean()
    cases = (52000 + s.loc[take, "p"]).astype(int)
    compare(
        f"group{group}:meanxtreme",
        pdata.loc[cases, "meanxtreme"],
        np.repeat(ext[take].mean(), take.sum()),
    )
    compare(
        f"group{group}:avgsd", pdata.loc[cases, "avgsd"], np.repeat(avg_sd, take.sum())
    )
    compare(
        f"group{group}:genvar",
        pdata.loc[cases, "genvar"],
        np.repeat(genvar, take.sum()),
        1e-10,
    )
    assert (pdata.loc[cases, "groupsize"] == take.sum()).all()
    group_summary.append(
        {
            "group": 5200 + int(group),
            "n": int(take.sum()),
            "rank": int(np.linalg.matrix_rank(cov)),
            "smallest_eigenvalue": eigen.min(),
            "genvar": genvar,
            "avgsd": avg_sd,
        }
    )

# Compare original field-file ratings to the authored merged version, retaining both.
variants = []
for wave, raw, suffix, key in [(1, pre, "b", "p"), (2, post, "a", "pp")]:
    for number in range(6, 36):
        original = s[key].map(raw[f"d20{number:02}{suffix}"]).replace(98, np.nan)
        field = f"d20{number:02}" + ("p" if wave == 2 else "")
        bad = ~np.isclose(original, s[field], rtol=0, atol=1e-12, equal_nan=True)
        for i in np.flatnonzero(bad):
            variants.append(
                {
                    "p": int(s.p.iloc[i]),
                    "wave": wave,
                    "field": field,
                    "original_field_file_value": original.iloc[i],
                    "merged_value": s[field].iloc[i],
                }
            )

# Departure absence is defined by reviewed POST identity, never by all-DK ratings.
absent = s.pp.isna() & s.preandpost.isna()
assert absent.sum() == 34 and not set(s.loc[absent, "p"]).intersection(post.index)
assert s.loc[absent, [f"d20{i:02}p" for i in range(6, 36)]].isna().all().all()
assert s.loc[absent, [f"post_d304{i}" for i in range(3, 7)]].isna().all().all()
absence = wide.loc[
    ids[absent],
    [f"{n}_t2" for n in batteries]
    + [
        "knowledge_t1",
        "knowledge_t2",
        "knowledge_joint",
        "knowledge_gain",
        "knowledge_gain_joint",
        "log_knowledge_joint",
        "high_knowledge_joint",
    ],
].copy()
absence.insert(0, "p", s.loc[absent, "p"].astype(int).to_numpy())
absence.to_csv(OUT / "absent_departure_current_values.csv", index=True)
all_missing = s[[f"d20{i:02}p" for i in range(6, 36)]].isna().all(axis=1)
matched_blank = s.loc[
    all_missing & ~absent, ["p", "pp", "preandpost", "groupnum"]
].copy()
assert len(matched_blank) == 1
matched_blank.to_csv(OUT / "matched_all_nonanswer_ratings.csv", index=False)
npfields = [c for c in s if c.endswith("np")]
nprows = s[npfields].notna().any(axis=1)
s.loc[
    nprows, ["p", "pp", "rnum", "grpnum", "Gender", "Age", "____0np", "____1np"]
].to_csv(OUT / "nonparticipant_block_identity_caution.csv", index=False)

# Candidate source selection under published Township Image definition; no adoption.
proposed = {}
proposal = []
for wave in (1, 2):
    value, count, fields = battery([8, 9, 25, 27], wave, True)
    proposed[wave] = value
    old = expected[f"township_image_t{wave}"]
    changed = ~np.isclose(old, value, rtol=0, atol=1e-12)
    for i in np.flatnonzero(changed):
        proposal.append(
            {
                "p": int(s.p.iloc[i]),
                "caseid": 52000 + int(ids.iloc[i]),
                "source_row": int(s.source_row.iloc[i]),
                "historical_selected": bool(selected.iloc[i]),
                "wave": wave,
                "old_value": old[i],
                "proposed_value": value[i],
                "old_n_observed": int(
                    s[
                        [
                            "d2025" + ("p" if wave == 2 else ""),
                            "d2031" + ("p" if wave == 2 else ""),
                        ]
                    ]
                    .iloc[i]
                    .notna()
                    .sum()
                ),
                "proposed_n_observed": int(count[i]),
            }
        )
newbaseline = baseline.copy()
newbaseline[:, 6] = proposed[1]
newext = np.abs(newbaseline - 0.5).mean(axis=1)
effects = []
derived_proposal = []
for i in np.flatnonzero(np.abs(ext - newext) > 1e-12):
    derived_proposal.append(
        {
            "p": int(s.p.iloc[i]),
            "caseid": 52000 + int(s.p.iloc[i]),
            "historical_selected": bool(selected.iloc[i]),
            "field": "attitude_extremity",
            "old_value": ext[i],
            "proposed_value": newext[i],
        }
    )
effects.append(
    {
        "field": "chi.t1att7",
        "n_changed": int(
            (
                np.abs(expected["township_image_t1"][selected] - proposed[1][selected])
                > 1e-12
            ).sum()
        ),
    }
)
effects.append(
    {
        "field": "chi.t2att7",
        "n_changed": int(
            (
                np.abs(expected["township_image_t2"][selected] - proposed[2][selected])
                > 1e-12
            ).sum()
        ),
    }
)
effects.append(
    {
        "field": "attextreme",
        "n_changed": int((np.abs(ext[selected] - newext[selected]) > 1e-12).sum()),
    }
)
for name in ["meanxtreme", "avgsd", "genvar"]:
    total = 0
    for group in sorted(s.loc[selected, "groupnum"].unique()):
        take = selected & s.groupnum.eq(group)
        x = newbaseline[take]
        if name == "meanxtreme":
            value = newext[take].mean()
        elif name == "avgsd":
            value = np.std(x, axis=0, ddof=1).mean()
        else:
            value = np.sqrt(
                np.sqrt(np.linalg.det(np.cov(x, rowvar=False)) ** 2) ** (1 / 9)
            )
        cases = (52000 + s.loc[take, "p"]).astype(int)
        old = pdata.loc[cases, name]
        changed = np.abs(old - value) > 1e-12
        total += int(changed.sum())
        for case in old.index[changed]:
            derived_proposal.append(
                {
                    "p": int(case - 52000),
                    "caseid": int(case),
                    "historical_selected": True,
                    "field": name,
                    "old_value": old.loc[case],
                    "proposed_value": value,
                }
            )
    effects.append({"field": name, "n_changed": total})

pd.DataFrame(checks).to_csv(OUT / "index_checks.csv", index=False)
pd.DataFrame(coverage).to_csv(OUT / "index_coverage.csv", index=False)
pd.DataFrame(group_summary).to_csv(OUT / "group_checks.csv", index=False)
pd.DataFrame(variants).to_csv(OUT / "raw_merged_rating_versions.csv", index=False)
pd.DataFrame(proposal).to_csv(OUT / "township_image_proposal.csv", index=False)
pd.DataFrame(effects).to_csv(OUT / "township_image_selected_impact.csv", index=False)
pd.DataFrame(derived_proposal).to_csv(
    OUT / "township_image_derived_proposal.csv", index=False
)
references = []
published = {
    "industrial_roads": (153, 0.623, 0.610),
    "village_roads": (158, 0.597, 0.538),
    "main_roads": (173, 0.624, 0.604),
    "commercial_roads": (121, 0.642, 0.562),
    "wenchang_main_avenue": (160, 0.825, 0.924),
    "other_parks": (174, 0.714, 0.684),
    "township_image": (176, 0.663, 0.618),
    "cultural_heritage": (136, 0.590, 0.491),
    "sewage": (194, 0.829, 0.921),
}
for name, nums in batteries.items():
    for version, fields in [("historical", nums)] + (
        [("published_appendix", [8, 9, 25, 27])] if name == "township_image" else []
    ):
        a, _, _ = battery(fields, 1, name in ["other_parks", "township_image"], False)
        b, _, _ = battery(fields, 2, name in ["other_parks", "township_image"], False)
        paired = np.isfinite(a) & np.isfinite(b) & s.preandpost.notna().to_numpy()
        n, pa, pb = published[name]
        references.append(
            {
                "index": name,
                "version": version,
                "paired_n": int(paired.sum()),
                "baseline": a[paired].mean(),
                "departure": b[paired].mean(),
                "published_n": n,
                "published_baseline": pa,
                "published_departure": pb,
            }
        )
pd.DataFrame(references).to_csv(OUT / "published_index_comparison.csv", index=False)
absence_counts = []
for name in absence.columns:
    if name == "p" or name == "knowledge_t1":
        continue
    absence_counts.append(
        {
            "table": "respondent_measures",
            "field": name,
            "n_changed": int(absence[name].notna().sum()),
            "current_min": absence[name].min(),
            "current_max": absence[name].max(),
            "proposed": "missing",
        }
    )
observed_counts = []
for table in [
    "analysis_scores",
    "analysis_phase_scores",
    "analysis_item_responses",
    "analysis_phase_item_responses",
]:
    d = pd.read_parquet(ROOT / f"output/analysis/{table}.parquet")
    d = d[d.poll_id.eq("zeguo-2005") & d.respondent_id.isin(ids[absent])]
    wave = "t2"
    d = d[d.wave.eq(wave)]
    assert len(d) == (136 if "item" in table else 34)
    if "n_observed" in d:
        assert d.n_observed.isna().all()
        observed_counts.append(
            {
                "table": table,
                "field": "n_observed",
                "n_changed": len(d),
                "current_min": "missing",
                "current_max": "missing",
                "proposed": "0",
            }
        )
    for field in ["score", "n_correct", "correct"]:
        if field in d:
            assert d[field].eq(0).all()
            absence_counts.append(
                {
                    "table": table,
                    "field": field,
                    "n_changed": len(d),
                    "current_min": 0,
                    "current_max": 0,
                    "proposed": "missing",
                }
            )
    if "response_status" in d:
        assert d.response_status.eq("scored").all()
        absence_counts.append(
            {
                "table": table,
                "field": "response_status",
                "n_changed": len(d),
                "current_min": "scored",
                "current_max": "scored",
                "proposed": "wave_absent",
            }
        )
    if "wave_observed" in d:
        assert d.wave_observed.isna().all()
        absence_counts.append(
            {
                "table": table,
                "field": "wave_observed",
                "n_changed": len(d),
                "current_min": "unknown",
                "current_max": "unknown",
                "proposed": "FALSE",
            }
        )
    if "questionnaire_presence_status" in d:
        assert d.questionnaire_presence_status.eq("unknown").all()
        absence_counts.append(
            {
                "table": table,
                "field": "questionnaire_presence_status",
                "n_changed": len(d),
                "current_min": "unknown",
                "current_max": "unknown",
                "proposed": "absent",
            }
        )
for table in ["analysis_participants", "analysis_phase_participants"]:
    d = pd.read_parquet(ROOT / f"output/analysis/{table}.parquet")
    d = d[d.poll_id.eq("zeguo-2005") & d.respondent_id.isin(ids[absent])]
    assert len(d) == 34 and d.panel.eq(False).all()
historical = pd.read_parquet(
    ROOT / "output/respondent/historical_knowledge_items.parquet"
)
historical = historical[
    historical.poll_id.eq("zeguo-2005")
    & historical.respondent_id.isin(ids[absent])
    & historical.wave.eq(2)
]
assert len(historical) == 136 and historical.correct.eq(0).all()
absence_counts.append(
    {
        "table": "historical_knowledge_items",
        "field": "correct",
        "n_changed": 136,
        "current_min": 0,
        "current_max": 0,
        "proposed": "missing",
    }
)
absence_counts.extend(observed_counts)
pd.DataFrame(absence_counts).to_csv(
    OUT / "absent_departure_proposed_changes.csv", index=False
)
counterfactual = wide.copy()
for name in absence.columns:
    if name not in ["p", "knowledge_t1"]:
        counterfactual.loc[ids[absent], name] = np.nan
assert np.array_equal(
    wide.loc[ids[~absent]].to_numpy(),
    counterfactual.loc[ids[~absent]].to_numpy(),
    equal_nan=True,
)
assert np.array_equal(wide.knowledge_t1, counterfactual.knowledge_t1, equal_nan=True)
assert not absent[selected].any()
assert (
    counterfactual.loc["90", "knowledge_t2"] == 0
    and counterfactual.loc["90", "sewage_t2"] == 0.5
)
print(
    "Knowledge/absence counterfactual invariants passed; "
    "main233 and all matched POST values preserved."
)
files = [
    "data/zeguo-2005/survey.parquet",
    "data/zeguo-2005/source-materials/pre.parquet",
    "data/zeguo-2005/source-materials/post.parquet",
    "data/zeguo-2005/source-materials/merged.parquet",
    "data/zeguo-2005/source-materials/questionnaire.pdf",
    "data/zeguo-2005/papers/china-zeguo-bjps.pdf",
]
pd.DataFrame(
    [
        {"file": f, "sha256": hashlib.sha256((ROOT / f).read_bytes()).hexdigest()}
        for f in files
    ]
).to_csv(OUT / "source_hashes.csv", index=False)
print(
    f"{len(checks)} comparisons passed; no unexplained differences. "
    "Absence and Township Image alternatives retained as proposals only."
)
