--
-- PostgreSQL database dump
--

-- Dumped from database version 11.4
-- Dumped by pg_dump version 12.0

-- Started on 2019-11-29 10:42:01

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
-- TOC entry 2 (class 3079 OID 19576)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

#COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 212 (class 1259 OID 21154)
-- Name: dataset; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dataset (
    dataset_id integer NOT NULL,
    dataset_uri text NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 21160)
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
-- TOC entry 214 (class 1259 OID 21162)
-- Name: feature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature (
    feature_id bigint NOT NULL,
    feature_uri text NOT NULL,
    feature_geometry public.geometry,
    dataset_id bigint,
    rdf_type_id bigint
);


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN feature.feature_geometry; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.feature.feature_geometry IS 'This field may be used later for a spatially-enabled version.';


--
-- TOC entry 215 (class 1259 OID 21168)
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
-- TOC entry 217 (class 1259 OID 81932)
-- Name: rdf_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rdf_type (
    rdf_type_id bigint NOT NULL,
    rdf_type_uri text NOT NULL
);


--
-- TOC entry 216 (class 1259 OID 81930)
-- Name: rdf_type_rdf_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.rdf_type ALTER COLUMN rdf_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.rdf_type_rdf_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 5152 (class 2606 OID 21171)
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (dataset_id);


--
-- TOC entry 5154 (class 2606 OID 21173)
-- Name: dataset dataset_uri_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_uri_uq UNIQUE (dataset_uri);


--
-- TOC entry 5156 (class 2606 OID 21175)
-- Name: feature feature_uri_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_uri_uq UNIQUE (feature_uri);


--
-- TOC entry 5160 (class 2606 OID 81939)
-- Name: rdf_type rdf_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rdf_type
    ADD CONSTRAINT rdf_type_pkey PRIMARY KEY (rdf_type_id);


--
-- TOC entry 5162 (class 2606 OID 81941)
-- Name: rdf_type rdf_type_uri_uq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rdf_type
    ADD CONSTRAINT rdf_type_uri_uq UNIQUE (rdf_type_uri);


--
-- TOC entry 5158 (class 2606 OID 21177)
-- Name: feature spatial_feature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT spatial_feature_pkey PRIMARY KEY (feature_id);


--
-- TOC entry 5163 (class 2606 OID 21178)
-- Name: feature feature_dataset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_dataset_id_fk FOREIGN KEY (dataset_id) REFERENCES public.dataset(dataset_id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;


--
-- TOC entry 5164 (class 2606 OID 81942)
-- Name: feature feature_rdf_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature
    ADD CONSTRAINT feature_rdf_type_id FOREIGN KEY (rdf_type_id) REFERENCES public.rdf_type(rdf_type_id) ON UPDATE CASCADE NOT VALID;


-- Completed on 2019-11-29 10:44:09

--
-- PostgreSQL database dump complete
--

