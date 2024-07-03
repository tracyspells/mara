import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'mara',

			social: {
				github: 'https://github.com/tracyspells/mara',
				discord: 'https://discord.gg/ApYYS9mEhT',
			},

			defaultLocale: 'en',
			locales: {
				en: { label: "English" },
			},

			sidebar: [
				{
					label: 'Start Here',
					items: [
						{ label: 'Introduction', link: '/getting-started/introduction/' },
						{ label: 'Installation', link: '/getting-started/installation/' },
					],
				},

				{
					label: 'Guides',
					items: [
						{ label: "How to create your first document", link: "/guides/your-first-document/" },
						{ label: "How to organize your documents", link: "/guides/organizing-documents/" },
						{ label: "How to use selectors", link: "/guides/your-first-selector/" },
						{ label: "How to subscribe to document changes", link: "/guides/document-changes/" },
					],
				},

				{
					label: 'API',
					items: [

						{
							label: 'Documents',
							items: [
								{ label: 'createDocument', link: '/reference/create-document' },
								{ label: 'Document', link: '/reference/create-document/document' },
							],
						},

						{
							label: 'Utils',
							items: [
								{ label: 'trackDocumentHistory', link: '/reference/utility/document-history' },
							],
						},

					],
				}
			],
		}),
	],
});
