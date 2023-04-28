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

CREATE FUNCTION public.thread_is_opened_checker() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare
		res varchar;
	BEGIN
		IF (select is_closed from theme_thread where theme_id = new.theme_id) then
		raise exception 'Access denied. The theme is closed.';		
		END IF;
		return NEW;
	END;
$$;

CREATE FUNCTION public.trigger_auto_theme_close_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	IF OLD.is_closed!=NEW.is_closed AND NEW.is_closed=true THEN
		NEW.close_date=now();
	END IF;
	RETURN NEW;
	END;
$$;

ALTER FUNCTION public.trigger_auto_theme_close_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.image (
    image_id smallint NOT NULL,
    post_id smallint NOT NULL,
    image character varying
);

ALTER TABLE public.image OWNER TO postgres;

ALTER TABLE public.image ALTER COLUMN image_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.image_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.post (
    post_id integer NOT NULL,
    author_uuid uuid NOT NULL,
    theme_id smallint NOT NULL,
    paragraph text NOT NULL,
    post_date timestamp without time zone DEFAULT now() NOT NULL
);

ALTER TABLE public.post OWNER TO postgres;

ALTER TABLE public.post ALTER COLUMN post_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.post_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.role (
    role_id smallint NOT NULL,
    role_name character varying NOT NULL
);

ALTER TABLE public.role OWNER TO postgres;

ALTER TABLE public.role ALTER COLUMN role_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.role_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public.theme_thread (
    theme_id smallint NOT NULL,
    author_uuid uuid NOT NULL,
    topic character varying NOT NULL,
    paragraph text,
    is_closed boolean DEFAULT false,
    open_date timestamp without time zone DEFAULT now() NOT NULL,
    close_date timestamp without time zone
);

ALTER TABLE public.theme_thread OWNER TO postgres;

ALTER TABLE public.theme_thread ALTER COLUMN theme_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.theme_thread_theme_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public."user" (
    user_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id smallint NOT NULL,
    login character varying NOT NULL,
    password character varying NOT NULL,
    name character varying NOT NULL,
    avatar character varying
);

ALTER TABLE public."user" OWNER TO postgres;

INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (1, '4d5934c9-70f3-422f-94fb-9777b13e316d', 1, 'test data', '2023-04-13 22:50:59.030834');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (2, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'new test data', '2023-04-14 09:31:14.703733');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (3, '4d5934c9-70f3-422f-94fb-9777b13e316d', 1, 'riehijgbreh', '2023-04-14 09:31:24.527537');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (6, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'riehijgbreh eht', '2023-04-14 09:33:49.803292');

INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (1, 'guest');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (2, 'user');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (3, 'moderator');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (4, 'administrator');

INSERT INTO public.theme_thread OVERRIDING SYSTEM VALUE VALUES (1, '4d5934c9-70f3-422f-94fb-9777b13e316d', 'first', 'tekst', true, '2023-04-13 22:49:24.417412', '2023-04-13 22:49:38.149785');
INSERT INTO public.theme_thread OVERRIDING SYSTEM VALUE VALUES (2, '4d5934c9-70f3-422f-94fb-9777b13e316d', 'second', 'test paragraph', false, '2023-04-13 22:50:00.823244', NULL);

INSERT INTO public."user" VALUES ('4d5934c9-70f3-422f-94fb-9777b13e316d', 4, 'root', '63a9f0ea7bb98050796b649e85481845', 'root', NULL);
INSERT INTO public."user" VALUES ('39ceeec0-17f6-4872-8339-135b35df4aaf', 4, 'admin', '21232f297a57a5a743894a0e4a801fc3', 'Администратор', NULL);
INSERT INTO public."user" VALUES ('d9ce0ae6-90b5-4a67-8cb1-57c96ce223b7', 2, 'user', 'ee11cbb19052e40b07aac0ca060c23ee', 'Пользователь', NULL);
INSERT INTO public."user" VALUES ('3621dda6-2a56-41c9-9966-adc8bac23b0e', 3, 'moderator', '0408f3c997f309c03b08bf3a4bc7b730', 'Модератор', NULL);

SELECT pg_catalog.setval('public.image_image_id_seq', 1, false);

SELECT pg_catalog.setval('public.post_post_id_seq', 6, true);

SELECT pg_catalog.setval('public.role_role_id_seq', 4, true);

SELECT pg_catalog.setval('public.theme_thread_theme_id_seq', 2, true);

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pk PRIMARY KEY (image_id);

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pk PRIMARY KEY (post_id);

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pk PRIMARY KEY (role_id);

ALTER TABLE ONLY public.theme_thread
    ADD CONSTRAINT theme_thread_pk PRIMARY KEY (theme_id);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk PRIMARY KEY (user_uuid);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_un UNIQUE (login);

CREATE TRIGGER auto_theme_close_date BEFORE UPDATE ON public.theme_thread FOR EACH ROW EXECUTE FUNCTION public.trigger_auto_theme_close_date();

CREATE TRIGGER thread_checker_insert BEFORE INSERT ON public.post FOR EACH ROW EXECUTE FUNCTION public.thread_is_opened_checker();

CREATE TRIGGER thread_checker_update BEFORE UPDATE ON public.post FOR EACH ROW EXECUTE FUNCTION public.thread_is_opened_checker();

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_fk FOREIGN KEY (post_id) REFERENCES public.post(post_id);

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_fk_1 FOREIGN KEY (theme_id) REFERENCES public.theme_thread(theme_id) ON DELETE CASCADE;

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_fk FOREIGN KEY (role_id) REFERENCES public.role(role_id) ON DELETE SET NULL;
