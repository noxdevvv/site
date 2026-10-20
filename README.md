# Painel de Vendas

Site com login e senha, gráfico e tabela de vendas em tempo real. Hospedagem gratuita no GitHub Pages e banco de dados no Supabase.

## Arquivos

- `index.html`: o site inteiro (login, painel, gráfico, cadastro de vendas, exportar CSV)
- `schema.sql`: cria a tabela de vendas com segurança por usuário
- `README.md`: este guia

## Passo 1: criar o banco no Supabase (grátis)

1. Crie uma conta em https://supabase.com e clique em **New project**.
2. Abra **SQL Editor > New query**, cole o conteúdo de `schema.sql` e clique em **Run**.
3. Vá em **Project Settings > API** e copie:
   - **Project URL**
   - **anon public key** (a chave `anon`, nunca a `service_role`)
4. Abra o `index.html`, procure `SUPABASE_URL` e `SUPABASE_ANON_KEY` e cole os dois valores.

A chave `anon` pode ficar no site. Quem protege os dados é a segurança por linha (RLS) criada no `schema.sql`.

## Passo 2: colocar no GitHub Pages

1. Crie um repositório no GitHub e envie `index.html`, `schema.sql` e `README.md`.
2. No repositório, vá em **Settings > Pages**.
3. Em **Branch**, escolha `main` e a pasta `/ (root)`, depois **Save**.
4. Em **Settings > Pages**, marque **Enforce HTTPS**.
5. Em cerca de 1 minuto o site fica em `https://SEU-USUARIO.github.io/NOME-DO-REPOSITORIO/`.

## Passo 3: configurar o login

No Supabase, em **Authentication > URL Configuration**, coloque o endereço do seu site em **Site URL**. Assim o link de confirmação de e-mail leva para o lugar certo.

Para impedir que qualquer pessoa crie conta, vá em **Authentication > Sign In / Providers > Email** e desative **Allow new users to sign up** depois de criar o seu usuário. Você também pode criar usuários em **Authentication > Users > Add user**.

## Segurança (faça estes ajustes no Supabase)

Já está no código: acesso só para quem fez login, cada usuário só vê as próprias vendas (RLS forçada), validações no banco, campos `user_id` e `created_at` travados, política de segurança do navegador (CSP), senha forte no cadastro, bloqueio temporário após 5 erros de login, logout automático após 30 minutos parado e proteção contra injeção de fórmulas no CSV.

Configure no painel do Supabase:

1. **Authentication > Sign In / Providers > Email:** deixe **Confirm email** ligado e, depois de criar seu usuário, desligue **Allow new users to sign up**.
2. **Authentication > Policies (Password security):** exija mínimo de 10 caracteres e ative a verificação de senhas vazadas (disponível nos planos pagos).
3. **Authentication > Rate Limits:** mantenha os limites padrão de e-mail e de login.
4. **Authentication > Multi-Factor:** ative o TOTP para exigir app autenticador, se quiser dupla verificação.
5. **Database > Advisors > Security Advisor:** rode e confirme que não há alertas na tabela `sales`.
6. **Nunca** coloque a chave `service_role` no `index.html`. Só a chave `anon` pode ficar no site.
7. Mantenha o repositório do GitHub sem senhas, tokens ou arquivos `.env`.

Observação: o GitHub Pages não permite cabeçalhos HTTP personalizados, por isso a CSP vai numa tag `<meta>`. Se quiser cabeçalhos completos (HSTS, X-Frame-Options), hospede na Cloudflare Pages ou Netlify.

## Como funciona

- Cada usuário só enxerga as próprias vendas.
- Ao registrar, editar ou excluir uma venda, todos os aparelhos conectados com a mesma conta atualizam sozinhos.
- Se você já tem vendas em outro sistema ou planilha, dá para importar em **Table Editor > sales > Insert > Import data from CSV**. Preencha `user_id` com o id do seu usuário (em Authentication > Users).

## Próximos passos possíveis

Perfis de vendedor e gerente, metas mensais, ranking de produtos, integração com sua loja ou ERP por API.
