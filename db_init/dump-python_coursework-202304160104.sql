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
set time zone 'Europe/Moscow';

CREATE FUNCTION public.thread_is_opened_checker() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare
		res varchar;
	BEGIN
		IF (select is_closed from thread where theme_id = new.theme_id) then
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

CREATE FUNCTION public.trigger_auto_theme_open_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	NEW.open_date=now();
	RETURN NEW;
	END;
$$;

ALTER FUNCTION public.trigger_auto_theme_open_date() OWNER TO postgres;

CREATE FUNCTION public.trigger_auto_theme_post_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	NEW.post_date=now();
	RETURN NEW;
	END;
$$;

ALTER FUNCTION public.trigger_auto_theme_post_date() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public.post (
    post_id integer NOT NULL,
    author_uuid uuid NOT NULL,
    theme_id smallint NOT NULL,
    paragraph text NOT NULL,
    post_date timestamp without time zone DEFAULT now()
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

CREATE TABLE public.thread (
    theme_id smallint NOT NULL,
    author_uuid uuid NOT NULL,
    topic character varying NOT NULL,
    paragraph text,
    is_closed boolean DEFAULT false,
    open_date timestamp without time zone DEFAULT now(),
    close_date timestamp without time zone
);

ALTER TABLE public.thread OWNER TO postgres;

ALTER TABLE public.thread ALTER COLUMN theme_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.thread_theme_id_seq
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
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (2, '4d5934c9-70f3-422f-94fb-9777b13e316d', 1, 'new test data', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (3, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'Многие современные приложения разработки также включают браузер классов, инспектор объектов и диаграмму иерархии классов — для использования при объектно-ориентированной разработке ПО. ИСР обычно предназначены для нескольких языков программирования — такие как IntelliJ IDEA, NetBeans, Eclipse, Qt Creator, Geany, Embarcadero RAD Studio, Code::Blocks, Xcode или Microsoft Visual Studio, но есть и IDE для одного определённого языка программирования — как, например, Visual Basic, Delphi, Dev-C++. Частный случай ИСР — среды визуальной разработки, которые включают в себя возможность наглядного редактирования интерфейса программы.', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (4, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'Использование ИСР для разработки программного обеспечения является прямой противоположностью способу, в котором используются несвязанные инструменты, такие как текстовый редактор, компилятор, и т. п. Интегрированные среды разработки были созданы для того, чтобы максимизировать производительность программиста благодаря тесно связанным компонентам с простыми пользовательскими интерфейсами. Это позволяет разработчику сделать меньше действий для переключения различных режимов, в отличие от дискретных программ разработки. Однако так как ИСР является сложным программным комплексом, то среда разработки сможет качественно ускорить процесс разработки ПО лишь после специального обучения. Для уменьшения барьера вхождения многие достаточно интерактивны, а для облегчения перехода с одной на другую интерфейс у одного производителя максимально близок, вплоть до использования одной ИСР.', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (5, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'ИСР обычно представляет собой единственную программу, в которой проводится вся разработка. Она, как правило, содержит много функций для создания, изменения, компилирования, развертывания и отладки программного обеспечения. Цель интегрированной среды заключается в том, чтобы объединить различные утилиты в одном модуле, который позволит абстрагироваться от выполнения вспомогательных задач, тем самым позволяя программисту сосредоточиться на решении собственно алгоритмической задачи и избежать потерь времени при выполнении типичных технических действий (например, вызове компилятора). Таким образом, повышается производительность труда разработчика. Также считается, что тесная интеграция задач разработки может далее повысить производительность за счёт возможности введения дополнительных функций на промежуточных этапах работы. Например, ИСР позволяет проанализировать код и тем самым обеспечить мгновенную обратную связь и уведомить о синтаксических ошибках.', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (6, '4d5934c9-70f3-422f-94fb-9777b13e316d', 2, 'Большинство современных ИСР являются графическими. Но первые ИСР использовались ещё до того, как стали широко применяться операционные системы с графическим интерфейсом — они были основаны на текстовом интерфейсе с использованием функциональных и горячих клавиш для вызова различных функций (например, Turbo Pascal, созданный фирмой Borland).', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (7, '17a7cfb4-40c1-404d-a00a-3668f8c8cd6b', 3, 'В выборе холодильного прибора не тип хладагента является решающим в том, в каком температурном диапазоне будет работать прибор. Тип компрессора и внутренних комплектующих также играет немаловажную роль. До недавнего времени бытовые холодильные приборы не могли исправно выполнять заявленные производителем функции при температуре окружающего воздуха ниже +10°C.', '2023-04-13 22:52:38.149785');
INSERT INTO public.post OVERRIDING SYSTEM VALUE VALUES (8, '17a7cfb4-40c1-404d-a00a-3668f8c8cd6b', 3, 'Спасибо за совет, Новенький!', '2023-04-14 9:29:45.135374');

INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (1, 'Гость');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (2, 'Пользователь');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (3, 'Модератор');
INSERT INTO public.role OVERRIDING SYSTEM VALUE VALUES (4, 'Администратор');

INSERT INTO public.thread OVERRIDING SYSTEM VALUE VALUES (1, '4d5934c9-70f3-422f-94fb-9777b13e316d', 'first', 'test', true, '2023-04-13 22:49:24.417412', '2023-04-14 09:31:14.703733');
INSERT INTO public.thread OVERRIDING SYSTEM VALUE VALUES (2, '4d5934c9-70f3-422f-94fb-9777b13e316d', 'Современные ИСР', 'Интегрированная среда разработки, ИСР (англ. Integrated development environment — IDE) — комплекс программных средств, используемый программистами для разработки программного обеспечения (ПО). Среда разработки включает в себя: текстовый редактор, транслятор (компилятор или интерпретатор), средства автоматизации сборки и отладчик. Иногда содержит также средства для интеграции с системами управления версиями и разнообразные инструменты для упрощения конструирования графического интерфейса пользователя.', true, '2023-04-13 22:49:24.417412', '2023-04-14 09:31:14.703733');
INSERT INTO public.thread OVERRIDING SYSTEM VALUE VALUES (3, 'd9ce0ae6-90b5-4a67-8cb1-57c96ce223b7', 'Хладагент R134a или R600a?', 'Чем отличаются, какие за и против. Холодильник с каким хладагентом выбрать. Заранее спасибо', true, '2023-04-13 22:49:24.417412', '2023-04-16 15:42:14.703733');
INSERT INTO public.thread OVERRIDING SYSTEM VALUE VALUES (4, '17a7cfb4-40c1-404d-a00a-3668f8c8cd6b', 'Всем привет!', 'Привет всем, я тут новичок, давайте знакомиться?', false, '2023-04-15 12:24:24.238724', NULL);

INSERT INTO public."user" VALUES ('4d5934c9-70f3-422f-94fb-9777b13e316d', 4, 'root', '63a9f0ea7bb98050796b649e85481845', 'Суперадмин', 'https://www.shareicon.net/data/256x256/2016/05/24/770117_people_512x512.png');
INSERT INTO public."user" VALUES ('d9ce0ae6-90b5-4a67-8cb1-57c96ce223b7', 2, 'user', 'ee11cbb19052e40b07aac0ca060c23ee', 'Пользователь', 'https://www.shareicon.net/data/256x256/2016/05/24/770118_people_512x512.png');
INSERT INTO public."user" VALUES ('17a7cfb4-40c1-404d-a00a-3668f8c8cd6b', 2, 'user2', '7e58d63b60197ceb55a1c487989a3720', 'Новенький', NULL);

SELECT pg_catalog.setval('public.post_post_id_seq', 2, true);

SELECT pg_catalog.setval('public.role_role_id_seq', 4, true);

SELECT pg_catalog.setval('public.thread_theme_id_seq', 4, true);

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pk PRIMARY KEY (post_id);

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pk PRIMARY KEY (role_id);

ALTER TABLE ONLY public.thread
    ADD CONSTRAINT thread_pk PRIMARY KEY (theme_id);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk PRIMARY KEY (user_uuid);

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_un UNIQUE (login);

CREATE TRIGGER auto_theme_open_date BEFORE INSERT ON public.thread FOR EACH ROW EXECUTE FUNCTION public.trigger_auto_theme_open_date();

CREATE TRIGGER auto_theme_close_date BEFORE UPDATE ON public.thread FOR EACH ROW EXECUTE FUNCTION public.trigger_auto_theme_close_date();

CREATE TRIGGER thread_checker_insert BEFORE INSERT ON public.post FOR EACH ROW EXECUTE FUNCTION public.thread_is_opened_checker();

CREATE TRIGGER thread_checker_update BEFORE UPDATE ON public.post FOR EACH ROW EXECUTE FUNCTION public.thread_is_opened_checker();

CREATE TRIGGER auto_post_date BEFORE INSERT ON public.post FOR EACH ROW EXECUTE FUNCTION public.trigger_auto_theme_post_date();

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_fk_1 FOREIGN KEY (theme_id) REFERENCES public.thread(theme_id) ON DELETE CASCADE;

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_fk FOREIGN KEY (role_id) REFERENCES public.role(role_id) ON DELETE SET NULL;
