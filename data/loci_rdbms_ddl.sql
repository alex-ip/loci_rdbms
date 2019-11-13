--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 12.0

-- Started on 2019-11-14 08:37:47

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 68975)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 4253 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET default_tablespace = '';

--
-- TOC entry 215 (class 1259 OID 70522)
-- Name: containment; Type: TABLE; Schema: public; Owner: loci
--

CREATE TABLE public.containment (
    container_feature_id bigint NOT NULL,
    contained_feature_id bigint NOT NULL,
    linkset_id integer NOT NULL
);


ALTER TABLE public.containment OWNER TO loci;

--
-- TOC entry 214 (class 1259 OID 70507)
-- Name: dataset; Type: TABLE; Schema: public; Owner: loci
--

CREATE TABLE public.dataset (
    dataset_id integer NOT NULL,
    dataset_uri text NOT NULL
);


ALTER TABLE public.dataset OWNER TO loci;

--
-- TOC entry 218 (class 1259 OID 70606)
-- Name: dataset_dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: loci
--

ALTER TABLE public.dataset ALTER COLUMN dataset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dataset_dataset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 212 (class 1259 OID 70482)
-- Name: feature; Type: TABLE; Schema: public; Owner: loci
--

CREATE TABLE public.feature (
    feature_id bigint NOT NULL,
    feature_uri text NOT NULL,
    feature_area_m2 double precision,
    feature_geometry public.geometry,
    dataset_id bigint
);


ALTER TABLE public.feature OWNER TO loci;

--
-- TOC entry 4254 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN feature.feature_geometry; Type: COMMENT; Schema: public; Owner: loci
--

COMMENT ON COLUMN public.feature.feature_geometry IS 'This field may be used later for a spatially-enabled version.';


--
-- TOC entry 216 (class 1259 OID 70527)
-- Name: linkset; Type: TABLE; Schema: public; Owner: loci
--

CREATE TABLE public.linkset (
    linkset_id integer NOT NULL,
    linkset_uri text NOT NULL
);


ALTER TABLE public.linkset OWNER TO loci;

--
-- TOC entry 219 (class 1259 OID 70608)
-- Name: linkset_linkset_id_seq; Type: SEQUENCE; Schema: public; Owner: loci
--

ALTER TABLE public.linkset ALTER COLUMN linkset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.linkset_linkset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 70542)
-- Name: overlap; Type: TABLE; Schema: public; Owner: loci
--

CREATE TABLE public.overlap (
    feature1_id bigint NOT NULL,
    feature2_id bigint NOT NULL,
    linkset_id integer NOT NULL,
    overlap_area_m2 double precision NOT NULL
);


ALTER TABLE public.overlap OWNER TO loci;

--
-- TOC entry 213 (class 1259 OID 70495)
-- Name: spatial_feature_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: loci
--

ALTER TABLE public.feature ALTER COLUMN feature_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.spatial_feature_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4110 (class 2606 OID 70526)
-- Name: containment contains_pkey; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.containment
    ADD CONSTRAINT contains_pkey PRIMARY KEY (container_feature_id, contained_feature_id);


--
-- TOC entry 4106 (class 2606 OID 70562)
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (dataset_id);


--
-- TOC entry 4108 (class 2606 OID 70516)
-- Name: dataset dataset_uri_uq; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_uri_uq UNIQUE (dataset_uri);


--
-- TOC entry 4102 (class 2606 OID 70506)
-- Name: feature feature_uri_uq; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_uri_uq UNIQUE (feature_uri);


--
-- TOC entry 4112 (class 2606 OID 70577)
-- Name: linkset linkset_pkey; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.linkset
    ADD CONSTRAINT linkset_pkey PRIMARY KEY (linkset_id);


--
-- TOC entry 4114 (class 2606 OID 70536)
-- Name: linkset linkset_uri_uq; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.linkset
    ADD CONSTRAINT linkset_uri_uq UNIQUE (linkset_uri);


--
-- TOC entry 4116 (class 2606 OID 70546)
-- Name: overlap overlap_pkey; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.overlap
    ADD CONSTRAINT overlap_pkey PRIMARY KEY (feature1_id, feature2_id);


--
-- TOC entry 4104 (class 2606 OID 70501)
-- Name: feature spatial_feature_pkey; Type: CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT spatial_feature_pkey PRIMARY KEY (feature_id);


--
-- TOC entry 4118 (class 2606 OID 70583)
-- Name: containment containment_linkset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.containment
    ADD CONSTRAINT containment_linkset_id_fk FOREIGN KEY (linkset_id) REFERENCES public.linkset(linkset_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4117 (class 2606 OID 70563)
-- Name: feature feature_dataset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_dataset_id_fk FOREIGN KEY (dataset_id) REFERENCES public.dataset(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 4119 (class 2606 OID 70597)
-- Name: overlap overlap_linkset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: loci
--

ALTER TABLE ONLY public.overlap
    ADD CONSTRAINT overlap_linkset_id_fk FOREIGN KEY (linkset_id) REFERENCES public.linkset(linkset_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4255 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.spatial_ref_sys TO loci;


-- Completed on 2019-11-14 08:37:48

--
-- PostgreSQL database dump complete
--

