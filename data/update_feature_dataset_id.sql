update feature
set dataset_id = (
	select dataset_id
	from dataset where feature.feature_uri like dataset.dataset_uri || '%'
	)
where dataset_id is null
