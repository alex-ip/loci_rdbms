SELECT dataset_id, dataset_uri, count(distinct feature_id)
FROM public.feature
INNER JOIN dataset using(dataset_id)
GROUP BY dataset_id, dataset_uri
