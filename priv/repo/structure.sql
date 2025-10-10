--
-- PostgreSQL database dump
--

\restrict eiltmrJBOejjKOrtiO7sFGdfo8VrIWpv4klkPyMogKsfGOFKuplEyoXca9nBewp

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: clocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clocks (
    id bigint NOT NULL,
    "time" timestamp(0) without time zone,
    status boolean DEFAULT false NOT NULL,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: clocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clocks_id_seq OWNED BY public.clocks.id;


--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_requests (
    id bigint NOT NULL,
    leave_type character varying(255),
    start_date date,
    end_date date,
    reason text,
    status character varying(255),
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.leave_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.leave_requests_id_seq OWNED BY public.leave_requests.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: team_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_memberships (
    id bigint NOT NULL,
    user_id bigint,
    team_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: team_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_memberships_id_seq OWNED BY public.team_memberships.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying(255),
    manager_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    password_hash character varying(255),
    skills character varying(255),
    role_id bigint,
    address character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: working_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.working_times (
    id bigint NOT NULL,
    start timestamp(0) without time zone,
    "end" timestamp(0) without time zone,
    user_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    shift_type character varying(255) DEFAULT 'day'::character varying NOT NULL,
    overtime boolean DEFAULT false NOT NULL,
    CONSTRAINT shift_type_must_be_day_or_night CHECK (((shift_type)::text = ANY ((ARRAY['day'::character varying, 'night'::character varying])::text[])))
);


--
-- Name: working_times_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.working_times_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: working_times_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.working_times_id_seq OWNED BY public.working_times.id;


--
-- Name: clocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clocks ALTER COLUMN id SET DEFAULT nextval('public.clocks_id_seq'::regclass);


--
-- Name: leave_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests ALTER COLUMN id SET DEFAULT nextval('public.leave_requests_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: team_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships ALTER COLUMN id SET DEFAULT nextval('public.team_memberships_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: working_times id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_times ALTER COLUMN id SET DEFAULT nextval('public.working_times_id_seq'::regclass);


--
-- Name: clocks clocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clocks
    ADD CONSTRAINT clocks_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: team_memberships team_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: working_times working_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_times
    ADD CONSTRAINT working_times_pkey PRIMARY KEY (id);


--
-- Name: clocks_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX clocks_user_id_index ON public.clocks USING btree (user_id);


--
-- Name: leave_requests_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX leave_requests_user_id_index ON public.leave_requests USING btree (user_id);


--
-- Name: roles_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roles_name_index ON public.roles USING btree (name);


--
-- Name: team_memberships_team_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_memberships_team_id_index ON public.team_memberships USING btree (team_id);


--
-- Name: team_memberships_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX team_memberships_user_id_index ON public.team_memberships USING btree (user_id);


--
-- Name: teams_manager_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX teams_manager_id_index ON public.teams USING btree (manager_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_role_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_role_id_index ON public.users USING btree (role_id);


--
-- Name: working_times_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX working_times_user_id_index ON public.working_times USING btree (user_id);


--
-- Name: clocks clocks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clocks
    ADD CONSTRAINT clocks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: leave_requests leave_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: team_memberships team_memberships_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: team_memberships team_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_memberships
    ADD CONSTRAINT team_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: teams teams_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.users(id);


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE RESTRICT;


--
-- Name: working_times working_times_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.working_times
    ADD CONSTRAINT working_times_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict eiltmrJBOejjKOrtiO7sFGdfo8VrIWpv4klkPyMogKsfGOFKuplEyoXca9nBewp

INSERT INTO public."schema_migrations" (version) VALUES (20250924120421);
INSERT INTO public."schema_migrations" (version) VALUES (20250924122630);
INSERT INTO public."schema_migrations" (version) VALUES (20250924124525);
INSERT INTO public."schema_migrations" (version) VALUES (20251003090234);
INSERT INTO public."schema_migrations" (version) VALUES (20251003091505);
INSERT INTO public."schema_migrations" (version) VALUES (20251003092200);
INSERT INTO public."schema_migrations" (version) VALUES (20251003154515);
INSERT INTO public."schema_migrations" (version) VALUES (20251003155232);
INSERT INTO public."schema_migrations" (version) VALUES (20251008084756);
INSERT INTO public."schema_migrations" (version) VALUES (20251010133813);
