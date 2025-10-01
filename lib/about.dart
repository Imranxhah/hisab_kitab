import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About "Hisab Kitab"',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Info Section
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'About the App',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Hisab Kitab is a digital ledger and debt tracker designed to simplify '
              'the management of your daily transactions and outstanding dues. '
              'It provides a clean, intuitive interface to keep track of who owes '
              'you and whom you owe, making financial management seamless and transparent.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version: 1.0.0', // This can be dynamically loaded using the `package_info_plus` package
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),

            const SizedBox(height: 48),

            // Open Source Licenses Section
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Licenses & Credits',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This application uses several open-source libraries. We extend our '
              'gratitude to their creators for making this project possible.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            // The license content itself can be a separate widget for modularity
            _LicenseText(),

            const SizedBox(height: 48),

            // Developer Info Section
            Row(
              children: [
                Icon(
                  Icons.code,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Developed by',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This app was crafted with passion and dedication.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2025 Imran Shah',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LicenseText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Example Library 1
        _buildLibraryCredit(
          name: 'Hive',
          description: 'Fast, secure, and modern NoSQL database for Flutter.',
          license: 'Apache License 2.0',
        ),
        _buildDivider(),

        // Example Library 2
        _buildLibraryCredit(
          name: 'Google Fonts',
          description: 'A Flutter package to use fonts from fonts.google.com.',
          license: 'SIL Open Font License',
        ),
        _buildDivider(),

        // Example Library 3
        _buildLibraryCredit(
          name: 'intl',
          description: 'Internationalization and localization support.',
          license: 'BSD-3-Clause',
        ),
        _buildDivider(),

        // General License Notice
        const SizedBox(height: 16),
        Text(
          'General License Notice',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
          'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
          'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
          'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
          'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
          'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLibraryCredit({
    required String name,
    required String description,
    required String license,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'License: $license',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.0,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
