--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 12.0

-- Started on 2019-11-18 18:59:56

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
-- TOC entry 4228 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 213 (class 1259 OID 70507)
-- Name: dataset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset (
    dataset_id integer NOT NULL,
    dataset_uri text NOT NULL
);


--
-- TOC entry 214 (class 1259 OID 70606)
-- Name: dataset_dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: feature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature (
    feature_id bigint NOT NULL,
    feature_uri text NOT NULL,
    feature_geometry public.geometry,
    dataset_id bigint
);


--
-- TOC entry 4229 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN feature.feature_geometry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feature.feature_geometry IS 'This field may be used later for a spatially-enabled version.';


--
-- TOC entry 215 (class 1259 OID 84333)
-- Name: feature_feature_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.feature ALTER COLUMN feature_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.feature_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4091 (class 2606 OID 70562)
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (dataset_id);


--
-- TOC entry 4093 (class 2606 OID 70516)
-- Name: dataset dataset_uri_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_uri_uq UNIQUE (dataset_uri);


--
-- TOC entry 4087 (class 2606 OID 139529)
-- Name: feature feature_uri_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_uri_uq UNIQUE (feature_uri);


--
-- TOC entry 4089 (class 2606 OID 70501)
-- Name: feature spatial_feature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT spatial_feature_pkey PRIMARY KEY (feature_id);


--
-- TOC entry 4094 (class 2606 OID 70563)
-- Name: feature feature_dataset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_dataset_id_fk FOREIGN KEY (dataset_id) REFERENCES public.dataset(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


-- Completed on 2019-11-18 18:59:58

--
-- PostgreSQL database dump complete
--

