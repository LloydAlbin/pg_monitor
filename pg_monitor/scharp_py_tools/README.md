# Example Package

This is a simple example package. You can use
[Github-flavored Markdown](https://guides.github.com/features/mastering-markdown/)
to write your content.

```python3

# See the test_modules.py code for the examples  

print ("Starting Tests")

password=''
import scharp_py_tools.pgpass
password = scharp_py_tools.pgpass.read_pgpass("sqltest", "reports_database", "postgres")
print ('Password:', password)


password=''
from scharp_py_tools import pgpass
pgpass.append_pgpass_files("/systems/services/postgres/.pgRO")
password = pgpass.read_pgpass("sqltest", "reports_database", "main_ro", "5432")
print ('Password:', password)

password=''
import scharp_py_tools
scharp_py_tools.pgpass.reset_pgpass_files()
password = scharp_py_tools.pgpass.read_pgpass("sqltest", "reports_database", "dw", "5432", "/web/external/security/.pgdw")
print ('Password:', password)

print ("Ending Tests")
```