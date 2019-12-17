SELECT rdf_type_uri, count(distinct feature_id)
FROM public.feature
INNER JOIN rdf_type using(rdf_type_id)
GROUP BY rdf_type_uri
order by 1